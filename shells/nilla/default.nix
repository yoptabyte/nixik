{config}: {
  config.shells.default = {
    systems = [ "x86_64-linux" ];
    shell = { mkShell, pkgs }:
      mkShell {
        packages = with pkgs; [
          npins
          nix
          git
          config.inputs.nilla-cli.result.packages.x86_64-linux.nilla-cli
          config.inputs.nilla-nixos.result.packages.x86_64-linux.nilla-nixos
        ];
      };
    settings = {
      pkgs = config.inputs.nixpkgs.result;
    };
  };
}
