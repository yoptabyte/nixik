{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/workstation.nix
    ../../modules/nixos/creative.nix
    ../../modules/nixos/gaming.nix
    ../../modules/home/hjem/xps15.nix
    inputs.xlibre-overlay.result.nixosModules.nvidia-ignore-ABI
  ];
  networking.hostName = "xps15";
  programs.nm-applet.enable = false;
  environment.systemPackages = with pkgs; [ jetbrains.idea dbeaver-bin postman ];

  # NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Required for Hyprland on NVIDIA
    modesetting.enable = true;
    # GTX 1050 Mobile (Pascal/Maxwell) does not support open-source kernel modules
    open = false;
    # Use stable proprietary driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # nvidia-settings GUI tool
    nvidiaSettings = true;
    # Power management for proper suspend/resume
    powerManagement.enable = true;
    # PRIME offload: Intel renders the display, NVIDIA is used on demand
    prime = {
      offload = {
        enable = true;
        # Creates the `nvidia-offload` wrapper command
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  services.pipewire.wireplumber = {
    enable = true;
    # Without this, WirePlumber leaves ALSA cards in "off" profile (no sinks created).
    # api.acp.auto-profile=false means WirePlumber defers to stored state;
    # with no stored state the device stays in "off" profile forever.
    extraConfig."51-alsa-auto-profile" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "device.name" = "~alsa_card.*"; } ];
          actions."update-props" = {
            "api.acp.auto-profile" = true;
            "api.acp.auto-port" = true;
          };
        }
      ];
    };
  };
  services.guix.enable = true;
  system.stateVersion = "26.05";
}
