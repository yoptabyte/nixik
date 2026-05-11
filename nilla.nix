let
  pins = import ./npins;
  nilla = import pins.nilla;
in
  nilla.create({config}:
  {
    includes = [
      "${pins.nilla-nixos}/modules/nixos.nix"
      ./shells
    ];
    config = {
      inputs = config.lib.attrs.mergeRecursive {
        nixpkgs = {
          src = pins.nixpkgs;
          settings = {
            configuration.allowUnfree = true;
            overlays = [
              (final: prev: {
                antigravity = final.callPackage (pins.antigravity + "/package.nix") { };
              })
            ];
          };
        };
        xlibre-overlay = {
          src = pins.xlibre-overlay;
          settings.inputs = {
            # Override path: inputs that flake-compat can't resolve as relative paths
            systems = pins.xlibre-overlay + "/systems.nix";
            fetchurl-sources = pins.xlibre-overlay + "/consumer-overridable/fetchurl-sources.nix";
            xserver-meson-flags = pins.xlibre-overlay + "/consumer-overridable/xserver-meson-flags.nix";
            # User's local driver choice override
            xlibre-drivers-overlay-choice = ./xlibre-build-options/driver-choice.nix;
          };
        };
      } (builtins.mapAttrs (name: value: { src = value; }) (builtins.removeAttrs pins [ "__functor" ]));
      systems.nixos.xps15 = {
        pkgs = config.inputs.nixpkgs.result.x86_64-linux;
        args = { inherit (config) inputs; };
        modules = [
          ./hosts/xps15_9550/configuration.nix
        ];
      };
    };
  })
