# Standalone devShell for this project
# Usage: nix-shell
let
  pins = import ./npins;
  pkgs = import pins.nixpkgs {
    system = builtins.currentSystem;
    config.allowUnfree = true;
  };
  nilla-cli = (import pins.nilla-cli).packages.nilla-cli.result.${builtins.currentSystem};
  nilla-nixos = (import pins.nilla-nixos).packages.nilla-nixos.result.${builtins.currentSystem};
in
  pkgs.mkShell {
    packages = with pkgs; [
      npins
      nix
      git
      nilla-cli
      nilla-nixos
    ];
  }
