# Standalone devShell for this project
# Usage: nix-shell
let
  pins = import ./npins;
  system = builtins.currentSystem;
  pkgs = import pins.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  nilla-cli = (import pins.nilla-cli).packages.nilla-cli.result.${system};
  nilla-nixos = let
    result = (import pins.nilla-nixos).packages.nilla-nixos.result;
  in if builtins.hasAttr system result then result.${system} else null;
in
  pkgs.mkShell {
    packages = with pkgs; [
      npins
      nix
      git
      nilla-cli
    ] ++ lib.optional (nilla-nixos != null) nilla-nixos;

    shellHook = ''
      # Workaround: codeberg.org occasionally returns 502 for xlibre-overlay.
      # Use the cached nix store path if available.
      XLIBRE_PATH="/nix/store/963dbws2hx7mcrwi95xf490hky39x9jm-xlibre-overlay.git-bcef0e9"
      if [ -d "$XLIBRE_PATH" ]; then
        export NPINS_OVERRIDE_xlibre_overlay="$XLIBRE_PATH"
      fi
    '';
  }
