{ pkgs, lib, ... }:
{
  # Fonts
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    monospace = [ "ComicTrueMono Nerd Font Mono" "JetBrainsMono Nerd Font Mono" ];
    sansSerif = [ "ComicTrueMono Nerd Font Mono" "JetBrainsMono Nerd Font Mono" ];
    serif = [ "ComicTrueMono Nerd Font Mono" "JetBrainsMono Nerd Font Mono" ];
  };
  fonts.packages = (with pkgs; [ nerd-fonts.jetbrains-mono nerd-fonts.symbols-only ]) ++ [
    (pkgs.callPackage ../../packages/comic-true-mono-nerd-font.nix { })
  ];

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

  # Tailscale VPN (includes the CLI package)
  services.tailscale.enable = true;

  # SSH access over Tailscale
  services.openssh = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

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
