# Build either attribute on another NixOS host using the same pinned inputs:
# nix-build packages/herdr-telegram-bundle.nix -A telegram
{ pkgs ? import (import ../npins).nixpkgs {} }:
{
  telegram = pkgs.callPackage ./herdr-telegram-agents.nix {};
  herdr = pkgs.callPackage ./herdr.nix {};
}
