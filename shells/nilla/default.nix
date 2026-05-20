{config, lib}: let
  system = builtins.currentSystem;
  nilla-cli = config.inputs.nilla-cli.result.packages.${system}.nilla-cli;
  nilla-nixos = let
    pkgs = config.inputs.nilla-nixos.result.packages;
  in if builtins.hasAttr system pkgs then pkgs.${system}.nilla-nixos else null;
in {
  config.shells.default = {
    systems = [ "x86_64-linux" "aarch64-darwin" ];
    shell = { mkShell, pkgs }:
      mkShell {
        packages = with pkgs; [
          npins
          nix
          git
          nilla-cli
        ] ++ lib.optional (nilla-nixos != null) nilla-nixos;
      };
    settings = {
      pkgs = config.inputs.nixpkgs.result;
    };
  };
}
