{ config, lib, pkgs, inputs, ... }:
let
  getPkg = name:
    let input = inputs.${name} or {}; in
    ((input.result.packages or {}).${pkgs.stdenv.hostPlatform.system} or {}).default or null;
  pkgsList = lib.filter (p: p != null) [
    (getPkg "zen-browser")
    (getPkg "helium")
  ];
in
{
  environment.systemPackages = pkgsList;
}