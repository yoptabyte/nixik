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

    # Auto garbage collection and store optimisation
    auto-optimise-store = true;
  };

  # Periodic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

}
