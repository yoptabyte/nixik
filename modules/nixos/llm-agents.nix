{ config, lib, pkgs, ... }:
{
  # Node.js is supplied by Nix; LLM agent CLIs are installed by the user with npm
  # into ~/.npm-global (see `npm config set prefix "$HOME/.npm-global"`).
  environment.systemPackages = [
    pkgs.nodejs_22
    pkgs.ollama
  ];

  # Keep npm global packages out of the Nix store.  This also avoids relying on
  # shell-specific expansion when setting npm's prefix interactively.
  environment.sessionVariables.NPM_CONFIG_PREFIX = "/home/yoptabyte/.npm-global";

  # npm-distributed CLIs bundle generic ELF executables.  nix-ld supplies a
  # compatible dynamic loader and the common runtime libraries on NixOS.
  programs.nix-ld.enable = true;

  # npm global binaries are exposed through Nushell's ~/.npm-global/bin PATH entry.
  environment.localBinInPath = true;

  # Ollama system service (local LLMs)
  services.ollama = {
    enable = true;
  };
}
