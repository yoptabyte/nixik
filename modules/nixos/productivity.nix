{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Knowledge base / notes
    obsidian

    # Spaced repetition (flashcards)
    anki

    # BitTorrent download manager
    qbittorrent

    # PDF / documents (vim-like viewer)
    zathura

    # Editors
    helix
    zed-editor
  ];

  # Obsidian requires electron — allowUnfree is already set in nilla.nix
}
