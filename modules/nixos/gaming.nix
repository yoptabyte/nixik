{ config, lib, pkgs, inputs, ... }:
let
  cachyos = import inputs.nix-cachyos-kernel.src;
  # Keep the cached upstream kernel, but build external modules (NVIDIA, etc.)
  # with this system's pinned nixpkgs and driver versions.
  cachyosKernel = cachyos.outputs.packages.${pkgs.stdenv.hostPlatform.system}.linux-cachyos-bore;
  goverlay-fixed = pkgs.callPackage ../../packages/goverlay.nix { };
  game-run = pkgs.writeShellScriptBin "game-run" ''
    ${lib.optionalString config.hardware.nvidia.prime.offload.enable ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __VK_LAYER_NV_optimus=NVIDIA_only
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
    ''}
    exec ${pkgs.gamemode}/bin/gamemoderun ${pkgs.mangohud}/bin/mangohud "$@"
  '';

  # Unity Hub wrapped with required system libraries
  unityhub-wrapped = pkgs.symlinkJoin {
    name = "unityhub-wrapped";
    paths = [ pkgs.unityhub ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/unityhub \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [
          alsa-lib
          atk
          cairo
          cups
          dbus
          expat
          fontconfig
          freetype
          gdk-pixbuf
          glib
          gtk3
          libdrm
          libGL
          libxkbcommon
          mesa
          nspr
          nss
          pango
          libx11
          libxscrnsaver
          libxcomposite
          libxcursor
          libxdamage
          libxext
          libxfixes
          libxi
          libxrandr
          libxrender
          libxtst
          libxcb
        ])} \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [
          xdg-utils
          pciutils
          usbutils
          lshw
        ])}
    '';
  };
in
{
  # Generic x86-64 BORE variant: usable on both Linux laptops without AVX
  # requirements or LTO complications for out-of-tree NVIDIA modules.
  boot.kernelPackages = pkgs.linuxPackagesFor cachyosKernel;
  boot.kernel.sysctl."vm.max_map_count" = 1048576;

  nix.settings = {
    extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
    extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamescope.enable = true;
  programs.hyprland.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    # Game engines
    unityhub-wrapped  # Unity Hub (wrapped with libs)
    godot_4           # Godot Engine 4.x

    # Wine / Proton (run Windows applications)
    wineWow64Packages.full  # Wine (WoW64, full build)
    winetricks     # Helper script

    # Lutris (game launcher)
    lutris
    heroic         # Epic / GOG / Amazon launcher

    # Gaming utilities
    mangohud       # Gaming HUD with metrics
    goverlay-fixed # MangoHud configuration GUI
    game-run       # GameMode + MangoHud + PRIME offload when enabled

    # Graphics diagnostics (Mesa/NVIDIA drivers come from hardware.graphics)
    vulkan-tools   # vulkaninfo and vkcube
    mesa-demos     # glxinfo / eglinfo for OpenGL renderer information
    libva-utils    # vainfo for hardware video decoding
    lm_sensors     # CPU temperatures and fan speeds
  ];

  # Intel laptops need dynamic frequency selection during games too.
  # The performance governor overrides balanced/power-saver CPU policy.
  programs.gamemode = {
    enable = true;
    settings.general = {
      desiredgov = "powersave";
      renice = 10;
      inhibit_screensaver = 1;
    };
  };
  users.users.yoptabyte.extraGroups = [ "gamemode" ];

  # Mesa provides Intel OpenGL and Vulkan in both ABIs; the NVIDIA module
  # adds its own matching proprietary drivers for PRIME offload.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Intel iGPU: VA-API hardware video decoding
      intel-media-driver
    ];
  };
}
