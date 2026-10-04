"""Line-oriented status feed: Pulse events and inexpensive backlight polling."""

from datetime import datetime
import os
from pathlib import Path
import re
import selectors
import subprocess
import time


def pactl(*args):
    try:
        return subprocess.check_output(["pactl", *args], text=True, stderr=subprocess.DEVNULL,
                                       timeout=0.5, env={**os.environ, "LC_ALL": "C"})
    except (OSError, subprocess.SubprocessError):
        return ""


def volume():
    level = re.search(r"(\d+)%", pactl("get-sink-volume", "@DEFAULT_SINK@"))
    muted = pactl("get-sink-mute", "@DEFAULT_SINK@")
    if "yes" in muted:
        return "<fc=#c84053> M</fc>"
    return f" {level.group(1)}%" if level else " ?"


def brightness():
    for device in sorted(Path("/sys/class/backlight").glob("*")):
        try:
            value = int((device / "brightness").read_text())
            maximum = int((device / "max_brightness").read_text())
            return f"󰃠 {round(100 * value / maximum)}%"
        except (OSError, ValueError, ZeroDivisionError):
            continue
    return "󰃠 ?"


def battery():
    for device in sorted(Path("/sys/class/power_supply").glob("BAT*")):
        try:
            capacity = int((device / "capacity").read_text())
            status = (device / "status").read_text().strip()
        except (OSError, ValueError):
            continue
        if status == "Charging":
            return f" {capacity}%"
        if capacity <= 10:
            return f"<fc=#cc241d> {capacity}%</fc>"
        return f" {capacity}%"
    return " ?"


def main():
    selector = selectors.DefaultSelector()
    subscriber = None
    next_audio = next_battery = next_subscribe = 0
    sound = power = ""
    previous = None
    try:
        while True:
            now = time.monotonic()
            if subscriber is None and now >= next_subscribe:
                subscriber = subprocess.Popen(["pactl", "subscribe"], stdout=subprocess.PIPE,
                                              stderr=subprocess.DEVNULL, env={**os.environ, "LC_ALL": "C"})
                selector.register(subscriber.stdout, selectors.EVENT_READ)
                next_subscribe = now + 2
                next_audio = 0
            if now >= next_audio:
                sound = volume()
                next_audio = now + 5  # Fallback if an event is lost during server restart.
            if now >= next_battery:
                power = battery()
                next_battery = now + 30
            fields = [datetime.now().strftime("%a %d/%m  %I:%M %p"), sound, brightness(), power]
            line = "<fc=#8a8980> | </fc>".join(fields)
            if line != previous:
                print(line, flush=True)
                previous = line
            for key, _ in selector.select(timeout=0.2):
                data = os.read(key.fileobj.fileno(), 65536)
                if not data:
                    selector.unregister(key.fileobj)
                    key.fileobj.close()
                    subscriber.wait()
                    subscriber = None
                    next_audio = 0
                elif any(kind in data for kind in (b"sink", b"server")):
                    next_audio = 0
    finally:
        if subscriber is not None:
            subscriber.terminate()
            subscriber.wait()
        selector.close()


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        pass
