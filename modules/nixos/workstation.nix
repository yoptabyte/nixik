{ inputs, pkgs, ... }:
{
  imports = [
    ./laptop.nix
    ./nix-settings.nix
    ./llm-agents.nix
    ./browsers.nix
    ./terminal.nix
    ./productivity.nix
    ./emacs.nix
    ./social.nix
    ./desktop/default.nix
    inputs.chatgpt-desktop-app.result.nixosModules.default
    ../home/hjem/common.nix
    (import "${inputs.hjem.src}/modules/nixos").default
    inputs.nixvim.result.nixosModules.nixvim
    ../home/nixvim.nix
    inputs.xlibre-overlay.result.nixosModules.overlay-xlibre-xserver
    inputs.xlibre-overlay.result.nixosModules.overlay-all-xlibre-drivers
  ];
  programs.nixvim.defaultEditor = true;
  programs.chatgpt-desktop-app.enable = true;
  programs.chatgpt-desktop-app.package =
    (pkgs.callPackage "${inputs.chatgpt-desktop-app.src}/pkgs/chatgpt-desktop-app" { }).overrideAttrs
      (old: {
        # The bundled remote-control-device-key.node links against these TPM libraries.
        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.tpm2-tss ];
      } // pkgs.lib.optionalAttrs (
        pkgs.stdenv.hostPlatform.system == "x86_64-linux"
        && old.src.outputHash == "sha256-zlmmG5Te9JzJIdaU75Uh7BdOuLZf2wwoXjuo5FIxoh8="
      ) {
        # Upstream's mutable /latest/ download changed after this recipe was pinned.
        # Apply only to the stale hash; newer upstream recipes use their own source.
        src = old.src.overrideAttrs (_: {
          outputHash = "sha256-lJjkFxMaJ4vONb//YnXSUsDTMvF6/AMT4LeCdJ9NNIo=";
        });
      });
}
