{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Boot
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Filesystems
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c1414b40-a6ba-4bf9-9bdd-9dac996c1325";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/52E2-F42B";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9c66c2c3-6097-4cf0-8422-4058ec4bb943"; }
    ];

  # NVIDIA Optimus (GTX 1050 Mobile)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # NVIDIA PRIME offload
  hardware.nvidia.prime = {
    offload.enable = true;
    nvidiaBusId = "PCI:2:0:0";
    intelBusId = "PCI:1:0:0";
  };

  # Enable early KMS for NVIDIA
  boot.kernelParams = [ "nvidia-drm.fbdev=1" ];
}