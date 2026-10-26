#!/usr/bin/env python3
"""Install Herdr integrations without requiring Python on the user's PATH."""

import argparse
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile

PYTHON_PACKAGE = "@python3@"


def write_json(path, document):
    text = json.dumps(document, ensure_ascii=False, indent=2) + "\n"
    if path.exists() and path.read_text() == text:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=path.name + ".", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as handle:
            handle.write(text)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def configure_hook(agent):
    if agent == "claude":
        path = Path.home() / ".claude/settings.json"
        script = Path.home() / ".claude/hooks/herdr-agent-state.sh"
    else:
        path = Path.home() / ".codex/hooks.json"
        script = Path.home() / ".codex/herdr-agent-state.sh"

    document = json.loads(path.read_text())
    command = shlex.join([
        "nix", "--extra-experimental-features", "nix-command flakes", "shell",
        PYTHON_PACKAGE, "--command", "bash", str(script), "session",
    ])
    seen = False
    groups = []
    for group in document["hooks"]["SessionStart"]:
        hooks = []
        for hook in group["hooks"]:
            if str(script) in hook.get("command", ""):
                if seen:
                    continue
                seen = True
                hook = dict(hook, command=command, timeout=30)
            hooks.append(hook)
        if hooks:
            groups.append(dict(group, hooks=hooks))
    if not seen:
        raise RuntimeError(f"Herdr did not install the {agent} SessionStart hook")
    document["hooks"]["SessionStart"] = groups
    write_json(path, document)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--herdr", default=shutil.which("herdr"))
    parser.add_argument("--agents", nargs="+", choices=["opencode", "claude", "codex"],
                        default=["opencode", "claude"])
    args = parser.parse_args()
    if not args.herdr:
        parser.error("Herdr is not on PATH; pass --herdr /path/to/herdr")
    for agent in args.agents:
        if agent in ("claude", "codex") and not (Path.home() / ("." + agent)).is_dir():
            print(f"Skipping {agent}: initialize the agent before installing its hook", flush=True)
            continue
        subprocess.run([args.herdr, "integration", "install", agent], check=True)
        if agent in ("claude", "codex"):
            configure_hook(agent)


if __name__ == "__main__":
    main()
