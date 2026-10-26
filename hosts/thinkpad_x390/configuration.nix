{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/workstation.nix
    ../../modules/home/hjem/thinkpad-x390.nix
  ];
  networking.hostName = "thinkpad-x390";
  modules.nixos.emacs.enable = false;
  system.stateVersion = "26.05";
}
