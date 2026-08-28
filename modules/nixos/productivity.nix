{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Knowledge base / notes
    obsidian

    # BitTorrent download manager
    qbittorrent

    # PDF / documents (vim-like viewer)
    zathura

    # File manager
    thunar

    # Editors
    helix
    zed-editor
  ];

  # Obsidian requires electron — allowUnfree is already set in nilla.nix
}
