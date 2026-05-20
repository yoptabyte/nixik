{ lib, config }:
let
  inherit (config) inputs;
in
{
  options.systems = {
    darwin = lib.options.create {
      description = "nix-darwin systems to create.";
      default.value = { };
      type = lib.types.attrs.of (lib.types.submodule (cfg: {
        options = {
          args = lib.options.create {
            description = "Additional arguments to pass to darwin modules.";
            type = lib.types.attrs.any;
            default.value = { };
          };
          system = lib.options.create {
            description = "The system architecture (e.g. aarch64-darwin, x86_64-darwin).";
            type = lib.types.string;
            default.value = "aarch64-darwin";
          };
          pkgs = lib.options.create {
            description = "The Nixpkgs instance to use.";
            type = lib.types.raw;
            default.value = null;
          };
          modules = lib.options.create {
            description = "A list of modules to use for the darwin system.";
            type = lib.types.list.of lib.types.raw;
            default.value = [ ];
          };
          result = lib.options.create {
            description = "The created nix-darwin system.";
            type = lib.types.raw;
            writable = false;
            default.value =
              let
                darwin = import inputs.nix-darwin.src { };
              in
              darwin.lib.darwinSystem {
                system = cfg.system;
                modules =
                  (lib.optional (cfg.pkgs != null) { nixpkgs.pkgs = cfg.pkgs; })
                  ++ cfg.modules;
                specialArgs = { inherit (config) inputs; } // cfg.args;
              };
          };
        };
      }));
    };
  };
}
