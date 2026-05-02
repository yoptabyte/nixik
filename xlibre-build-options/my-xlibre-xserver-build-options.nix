# XLibre XServer Build Options
# Intel + NVIDIA Optimus laptop

{ lib, pkgs }:

{
  driverList = [
    # Input drivers
    "xlibre-xf86-input-evdev"
    "xlibre-xf86-input-keyboard"
    "xlibre-xf86-input-libinput"
    "xlibre-xf86-input-mouse"

    # Video drivers
    "xlibre-xf86-video-intel"
    "xlibre-xf86-video-vesa"
  ];

  buildFlags = [
    "--with-xkb-dir=${lib.getDev pkgs.xkeyboard_config}/share/X11/xkb"
  ];
}
