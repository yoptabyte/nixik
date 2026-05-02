{ config, lib, pkgs, inputs, ... }:
let
  getPkg = name: fallback:
    let input = inputs.${name} or {}; in
    ((input.result.packages or {}).${pkgs.stdenv.hostPlatform.system} or {}).default or fallback;
in
{
  environment.systemPackages = with pkgs; [
    vesktop  # vesktop is only available in nixpkgs

    # AyuGram (from npins flake input)
    (getPkg "ayugram-desktop" telegram-desktop)
  ];
}
