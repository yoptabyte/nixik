let
  pins = import ./npins;
  nilla = import pins.nilla;
in
  nilla.create({config}:
  {
    includes = [
      "${pins.nilla-nixos}/modules/nixos.nix"
      ./modules/darwin/darwin.nix
      ./shells
    ];
    config = {
      inputs = config.lib.attrs.mergeRecursive {
        nixpkgs = {
          src = pins.nixpkgs;
          settings = {
            configuration = {
              allowUnfree = true;
              permittedInsecurePackages = [ "electron-40.10.5" ];
            };
            overlays = [
              (final: prev: if prev.stdenv.hostPlatform.isLinux then {
                antigravity = final.callPackage (pins.antigravity + "/package.nix") { };
              } else { })
              # anki 25.09.4: uv export of qt/pylib projects missing --no-dev pulls
              # the root dev group (pytest -> iniconfig) into offline resolution.
              # Fixed upstream in anki 26.08; remove once nixpkgs pin advances.
              (final: prev: {
                anki = prev.anki.overrideAttrs (old: {
                  buildPhase = prev.lib.replaceStrings
                    [
                      "uv export --project qt --extra qt --extra audio"
                      "uv export --project pylib | strip_versions"
                    ]
                    [
                      "uv export --project qt --no-dev --extra qt --extra audio"
                      "uv export --project pylib --no-dev | strip_versions"
                    ]
                    old.buildPhase;
                });
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

      systems.nixos.thinkpad-x390 = {
        pkgs = config.inputs.nixpkgs.result.x86_64-linux;
        args = { inherit (config) inputs; };
        modules = [
          ./hosts/thinkpad_x390/configuration.nix
        ];
      };

      systems.darwin.macbook = {
        system = "aarch64-darwin";
        pkgs = config.inputs.nixpkgs.result.aarch64-darwin;
        args = { inherit (config) inputs; };
        modules = [
          ./hosts/macbook/configuration.nix
        ];
      };
    };
  })
