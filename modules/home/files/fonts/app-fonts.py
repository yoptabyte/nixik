"""Update only font preferences, preserving other application settings."""
import configparser
import json
import os
from pathlib import Path
import re
import shutil
import sys
import xml.etree.ElementTree as ET

FONT = "ComicTrueMono Nerd Font Mono"
HOME = Path.home()
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))


def write_changed(path, content):
    old = path.read_text() if path.exists() else ""
    if old == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    backup = path.with_name(path.name + ".before-comic-font")
    if path.exists() and not backup.exists():
        shutil.copy2(path, backup)
    temp = path.with_name(path.name + ".comic-font.tmp")
    temp.write_text(content)
    temp.replace(path)
    print(f"Updated font settings: {path}")


def update_json(path, changes):
    data = json.loads(path.read_text()) if path.exists() else {}
    if all(data.get(key) == value for key, value in changes.items()):
        return
    data.update(changes)
    write_changed(path, json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def managed_css(path, css):
    begin, end = "/* BEGIN nixos-config fonts */", "/* END nixos-config fonts */"
    old = path.read_text() if path.exists() else ""
    block = begin + "\n" + css.strip() + "\n" + end
    pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.S)
    new = pattern.sub(lambda _: block, old) if pattern.search(old) else old.rstrip() + "\n\n" + block + "\n"
    write_changed(path, new.lstrip("\n"))


if "--xfconf-offline" in sys.argv:
    settings = CONFIG / "xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
    if settings.exists():
        tree = ET.parse(settings, parser=ET.XMLParser(target=ET.TreeBuilder(insert_comments=True)))
        channel = tree.getroot()
        gtk = channel.find("property[@name='Gtk']")
        if gtk is None:
            gtk = ET.SubElement(channel, "property", name="Gtk", type="empty")
        changed = False
        for name in ("FontName", "MonospaceFontName"):
            prop = gtk.find(f"property[@name='{name}']")
            if prop is None:
                prop = ET.SubElement(gtk, "property", name=name)
            if prop.get("type") != "string" or prop.get("value") != FONT + " 11":
                prop.set("type", "string")
                prop.set("value", FONT + " 11")
                changed = True
        if changed:
            write_changed(settings, '<?xml version="1.0" encoding="UTF-8"?>\n' + ET.tostring(channel, encoding="unicode") + "\n")


registry = CONFIG / "obsidian/obsidian.json"
if registry.exists():
    for vault in json.loads(registry.read_text()).get("vaults", {}).values():
        settings = Path(vault["path"]) / ".obsidian"
        if settings.is_dir():
            update_json(settings / "appearance.json", {
                "interfaceFontFamily": FONT, "textFontFamily": FONT,
                "monospaceFontFamily": FONT,
            })

vesktop = CONFIG / "vesktop/settings"
if vesktop.is_dir():
    managed_css(vesktop / "quickCss.css", f'''
    :root, .theme-dark, .theme-light {{
      --font-primary: "{FONT}", sans-serif !important;
      --font-display: "{FONT}", sans-serif !important;
      --font-headline: "{FONT}", sans-serif !important;
      --font-code: "{FONT}", monospace !important;
    }}
    ''')
    update_json(vesktop / "settings.json", {"useQuickCss": True})

for root in (CONFIG / "zen", HOME / ".zen"):
    profiles = root / "profiles.ini"
    if not profiles.exists():
        continue
    ini = configparser.ConfigParser()
    ini.read(profiles)
    for section in ini.sections():
        if not section.startswith("Profile") or not ini.has_option(section, "Path"):
            continue
        profile = Path(ini[section]["Path"])
        if ini[section].get("IsRelative", "1") == "1":
            profile = root / profile
        if not profile.is_dir():
            continue
        preferences = {"toolkit.legacyUserProfileCustomizations.stylesheets": True}
        for language in ("x-western", "x-cyrillic", "x-unicode"):
            for family in ("serif", "sans-serif", "monospace"):
                preferences[f"font.name.{family}.{language}"] = FONT
        user_js = profile / "user.js"
        text = user_js.read_text() if user_js.exists() else ""
        for key, value in preferences.items():
            line = f"user_pref({json.dumps(key)}, {json.dumps(value)});"
            pattern = re.compile(r'^[ \t]*user_pref\("' + re.escape(key) + r'"[ \t]*,.*?\);[ \t]*$', re.M)
            text = pattern.sub(lambda _: line, text) if pattern.search(text) else text.rstrip() + "\n" + line + "\n"
        write_changed(user_js, text.lstrip("\n"))
        selectors = ":root, body, button, input, textarea, select, label, description, menuitem, .tab-label"
        managed_css(profile / "chrome/userChrome.css",
                    f'{selectors} {{ font-family: "{FONT}" !important; }}')
        managed_css(profile / "chrome/userContent.css",
                    f'@-moz-document url-prefix("about:") {{ {selectors} {{ font-family: "{FONT}" !important; }} }}')
