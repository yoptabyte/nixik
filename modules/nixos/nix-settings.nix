{ config, lib, pkgs, ... }:
let
  # The Nix daemon runs post-build hooks as root, while Cachix credentials are
  # intentionally kept in the workstation user's private config.
  cachixConfig = "/home/yoptabyte/.config/cachix/cachix.dhall";
in
{
  # Non-flake Nix settings
  nix.settings = {
    # Enable nix command and flakes features (required by Nilla CLI)
    experimental-features = [ "nix-command" "flakes" ];

    # Binary caches
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://yoptanix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkN8ET+0zsk18K3D0/RCc="
      "yoptanix.cachix.org-1:A2xZalxcVrV8HpePEmaMlNo/77H7k3rboLcfMlFyPgg="
    ];

    # Auto-push locally built derivations to cachix
    post-build-hook = "/etc/nix/post-build-hook.sh";

    # Auto garbage collection and store optimisation
    auto-optimise-store = true;
  };

  environment.systemPackages = [ pkgs.cachix ];

  environment.etc."nix/post-build-hook.sh" = {
    text = ''
      #!/bin/sh
      set -eu
      set -f # disable globbing

      # Nix guarantees that OUT_PATHS is a space-separated list without spaces
      # in individual store paths. Word splitting below is therefore intended.
      paths="''${OUT_PATHS:-}"
      if [ -z "$paths" ]; then
        exit 0
      fi

      exec ${lib.getExe pkgs.cachix} -c ${lib.escapeShellArg cachixConfig} push yoptanix $paths
    '';
    mode = "0755";
  };

  # Periodic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

}
