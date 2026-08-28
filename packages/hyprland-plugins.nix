{ pkgs, lib, inputs }:
let
  hyprexpo = (pkgs.callPackage (inputs.hyprexpo.src + "/default.nix") { }).overrideAttrs (_: {
    patches = [ ../modules/nixos/desktop/hyprexpo-fit-workspaces.patch ];
  });
  phantomat = pkgs.hyprlandPlugins.mkHyprlandPlugin {
    hyprland = pkgs.hyprland;
    pluginName = "spatialoverview";
    version = "2e33ec1";
    src = pkgs.fetchFromGitHub {
      owner = "kaolti";
      repo = "phantomat";
      rev = "2e33ec12e9d0a7699c61307c1e04909badb75e75";
      hash = "sha256-GSYrefXb3XmPJkxDiroqC+FL/PBxM112GYVAUvvNeBU=";
    };
    patches = [ ../modules/nixos/desktop/phantomat-scoped-workspace.patch ];
    buildInputs = [ pkgs.lua5_4 ];
    enableParallelBuilding = true;
    dontUseCmakeConfigure = true;
    buildPhase = ''
      runHook preBuild
      make all
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib"
      mv spatialoverview.so "$out/lib/libspatialoverview.so"
      runHook postInstall
    '';
    meta = {
      description = "Phantomat with a workspace-scoped canvas";
      homepage = "https://github.com/kaolti/phantomat";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.linux;
    };
  };
in
{ inherit hyprexpo phantomat; }
