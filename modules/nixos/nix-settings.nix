{ config, lib, pkgs, ... }:
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
      set -f # disable globbing
      # Nix passes built paths via stdin and/or the OUT_PATHS env var.
      # Some derivations have no output paths; pushing nothing is not an error.
      paths="''${OUT_PATHS:-}"
      if [ -z "$paths" ]; then
        paths=$(cat)
      fi
      if [ -z "$paths" ]; then
        exit 0
      fi
      exec ${lib.getExe pkgs.cachix} push yoptanix $paths
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
