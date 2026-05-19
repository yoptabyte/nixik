{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vesktop
    ayugram-desktop
  ];
}
