{ pkgs, lib, ... }:
{
  # Fonts
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [ nerd-fonts.zed-mono nerd-fonts.symbols-only ];

  # Timezone
  time.timeZone = "Europe/Lisbon";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # Bootloader (UEFI)
  boot.loader.systemd-boot.enable = true;
  # Limit kernels and initrds kept on the EFI partition.
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # NetworkManager
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  # DNS servers (Google + Cloudflare)
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # PipeWire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;

  # Printing
  services.printing.enable = true;

  services.power-profiles-daemon.enable = true;

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };
  users.groups.docker = {};


  # Git configuration via NixOS module
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  # User
  users.users.yoptabyte = {
    isNormalUser = true;
    description = "yoptabyte";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    shell = pkgs.nushell;
  };

}
