{ inputs, ... }:
{
  imports = [
    ./laptop.nix
    ./nix-settings.nix
    ./llm-agents.nix
    ./browsers.nix
    ./terminal.nix
    ./productivity.nix
    ./emacs.nix
    ./social.nix
    ./desktop/default.nix
    ../home/hjem/common.nix
    (import "${inputs.hjem.src}/modules/nixos").default
    inputs.nixvim.result.nixosModules.nixvim
    ../home/nixvim.nix
    inputs.xlibre-overlay.result.nixosModules.overlay-xlibre-xserver
    inputs.xlibre-overlay.result.nixosModules.overlay-all-xlibre-drivers
  ];
  programs.nixvim.defaultEditor = true;
}
