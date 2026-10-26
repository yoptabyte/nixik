{ config, lib, pkgs, ... }:
let
  appFonts = pkgs.callPackage ../../packages/app-fonts.nix { };
  tapeback = pkgs.callPackage ../../packages/tapeback.nix { };
in
{
  environment.systemPackages = with pkgs; [
    # Knowledge base / notes
    obsidian
    basalt
    tapeback

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

  environment.sessionVariables = {
    TAPEBACK_LANGUAGE = "ru";
    TAPEBACK_VAULT_PATH = "/home/yoptabyte/ZVOnki";
    # Use the CPU build on both Linux laptops without pulling in CUDA.
    TAPEBACK_DEVICE = "cpu";
  };

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
