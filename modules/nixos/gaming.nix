{ config, lib, pkgs, ... }:
let
  # Unity Hub wrapped with required system libraries
  unityhub-wrapped = pkgs.symlinkJoin {
    name = "unityhub-wrapped";
    paths = [ pkgs.unityhub ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/unityhub \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [
          alsa-lib
          atk
          cairo
          cups
          dbus
          expat
          fontconfig
          freetype
          gdk-pixbuf
          glib
          gtk3
          libdrm
          libGL
          libxkbcommon
          mesa
          nspr
          nss
          pango
          libx11
          libxscrnsaver
          libxcomposite
          libxcursor
          libxdamage
          libxext
          libxfixes
          libxi
          libxrandr
          libxrender
          libxtst
          libxcb
        ])} \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [
          xdg-utils
          pciutils
          usbutils
          lshw
        ])}
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    # Game engines
    unityhub-wrapped  # Unity Hub (wrapped with libs)
    godot_4           # Godot Engine 4.x

    # Wine / Proton (run Windows applications)
    wine           # Wine (WoW64 by default)
    winetricks     # Helper script

    # Lutris (game launcher)
    lutris

    # Gaming utilities
    gamemode       # Performance optimisation
    mangohud       # Gaming HUD with metrics
  ];

  # Enable Steam (optional — uncomment if needed)
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true;
  #   dedicatedServer.openFirewall = true;
  # };

  # GameMode daemon
  programs.gamemode.enable = true;

  # 32-bit library support (needed for Wine and games)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
