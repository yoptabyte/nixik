{ writeShellApplication, python3, xfconf, glib, gsettings-desktop-schemas, procps }:

writeShellApplication {
  name = "app-fonts";
  runtimeInputs = [ python3 xfconf glib procps ];
  text = ''
    python ${../modules/home/files/fonts/app-fonts.py}
    export GSETTINGS_SCHEMA_DIR=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}/glib-2.0/schemas
    gsettings set org.gnome.desktop.interface font-name "ComicTrueMono Nerd Font Mono 11"
    gsettings set org.gnome.desktop.interface document-font-name "ComicTrueMono Nerd Font Mono 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "ComicTrueMono Nerd Font Mono 11"
    if pgrep -u "$(id -u)" -x xfconfd >/dev/null; then
      for property in /Gtk/FontName /Gtk/MonospaceFontName; do
        if xfconf-query -c xsettings -p "$property" >/dev/null 2>&1; then
          xfconf-query -c xsettings -p "$property" -s "ComicTrueMono Nerd Font Mono 11"
        else
          xfconf-query -c xsettings -p "$property" -n -t string -s "ComicTrueMono Nerd Font Mono 11"
        fi
      done
    else
      python ${../modules/home/files/fonts/app-fonts.py} --xfconf-offline
    fi
  '';
}
