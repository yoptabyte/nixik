"""Supervise XMonad's compositor and docks; re-create docks on RandR changes."""

import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import time


def query_outputs():
    result = subprocess.run(["xrandr", "--query"], capture_output=True, text=True, timeout=5)
    if result.returncode:
        raise RuntimeError(result.stderr.strip())
    outputs = {}
    current = None
    for line in result.stdout.splitlines():
        match = re.match(r"^(\S+) (connected|disconnected)\b(.*)", line)
        if match:
            name, state, rest = match.groups()
            geometry = re.search(r"\d+x\d+\+\d+\+\d+", rest)
            outputs[name] = {"connected": state == "connected", "geometry": geometry.group() if geometry else None,
                             "primary": "primary" in rest, "rate": None}
            current = outputs[name]
        elif current is not None and "*" in line:
            current["rate"] = float(re.search(r"([\d.]+)\*", line).group(1))
    return outputs


def monitor_command(outputs):
    """Enable the destination first, then disable every other output."""
    if outputs.get("DP-1", {}).get("connected"):
        target, mode, rate = "DP-1", "2560x1080", "100"
    elif outputs.get("eDP-1", {}).get("connected"):
        target, mode, rate = "eDP-1", "1920x1200", "59.95"
    else:
        return None
    chosen = outputs[target]
    correct = (chosen["geometry"] == mode + "+0+0" and chosen["primary"]
               and chosen["rate"] is not None and abs(chosen["rate"] - float(rate)) < 0.1)
    if correct and all(not data["geometry"] for name, data in outputs.items() if name != target):
        return None
    args = ["xrandr", "--output", target, "--mode", mode, "--rate", rate, "--pos", "0x0", "--primary"]
    for name in outputs:
        if name != target:
            args += ["--output", name, "--off"]
    return args


def stop(process):
    # Each child owns a process group, including xmobar's CommandReader.
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    try:
        process.wait(timeout=2)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait()


def main():
    children = {}
    config = Path.home() / ".config"
    commands = {
        "xmobar": ["xmobar", str(config / "xmobar/xmobarrc")],
        "trayer": ["trayer", "--edge", "bottom", "--align", "right", "--widthtype", "request",
                   "--width", "1", "--height", "22", "--SetDockType", "true", "--SetPartialStrut", "true",
                   "--transparent", "true", "--alpha", "0", "--tint", "0x282828", "--expand", "false",
                   "--padding", "2", "--iconspacing", "2", "--monitor", "primary"],
        "picom": ["picom", "--config", str(config / "picom/picom.conf")],
        "snixembed": ["snixembed"],
    }
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    previous = None
    try:
        # Migrate processes from the previous, unsupervised startup hook.
        for name in commands:
            subprocess.run(["pkill", "-u", str(os.getuid()), "-x", name], check=False)
        while True:
            try:
                outputs = query_outputs()
                command = monitor_command(outputs) if "--prefer-dp-1" in sys.argv else None
                if command:
                    subprocess.run(command, check=True, timeout=5)
                    outputs = query_outputs()
                fingerprint = repr(outputs)
                if previous != fingerprint:
                    # Reinitialize GLX as well: some drivers retain stale drawable state.
                    for name in ("xmobar", "trayer", "picom"):
                        if name in children:
                            stop(children.pop(name))
                    previous = fingerprint
            except (OSError, RuntimeError, subprocess.SubprocessError) as error:
                print(f"xmonad-session: {error}", file=sys.stderr, flush=True)
            for name, command in commands.items():
                if name not in children or children[name].poll() is not None:
                    if name in children:
                        stop(children.pop(name))
                    children[name] = subprocess.Popen(command, start_new_session=True)
            time.sleep(1)
    finally:
        for process in children.values():
            stop(process)


if __name__ == "__main__":
    main()
