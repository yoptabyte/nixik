{ config, lib, pkgs, ... }:
let
  appFonts = pkgs.callPackage ../../packages/app-fonts.nix { };
in
{
  environment.systemPackages = with pkgs; [
    # Knowledge base / notes
    obsidian
    basalt

    # BitTorrent download manager
    qbittorrent

    # PDF / documents (vim-like viewer)
    zathura

    # File manager
    thunar

    # Editors
    helix
    zed-editor
    appFonts
  ];

  systemd.user.services.app-fonts = {
    description = "Apply Comic True Mono to application font settings";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${appFonts}/bin/app-fonts";
    };
  };

  # Obsidian requires electron — allowUnfree is already set in nilla.nix
}
