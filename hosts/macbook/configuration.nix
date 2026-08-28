{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../../modules/darwin/desktop.nix
    ../../modules/home/hjem/macbook.nix
    # Nixvim
    inputs.nixvim.result.nixDarwinModules.nixvim
    ../../modules/home/nixvim.nix

    # Hjem nix-darwin module
    (import "${inputs.hjem.src}/modules/nix-darwin").default
  ];

  nixpkgs.config.allowUnfree = true;
  environment.variables.EDITOR = "nvim";

  # Fonts
  fonts.packages = with pkgs; [ nerd-fonts.zed-mono nerd-fonts.symbols-only ];

  # Hostname
  networking.hostName = "yoptabyte-macbook";
  networking.computerName = "yoptabyte-macbook";

  # Timezone
  time.timeZone = "Europe/Lisbon";

  # Locale
  system.defaults.NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
  system.defaults.NSGlobalDomain.AppleMetricUnits = 1;

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # Trackpad
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadRightClick = true;

  # Dock
  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;

  # Finder
  system.defaults.finder.FXPreferredViewStyle = "clmv";
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.ShowStatusBar = true;

  # Screenshots
  system.defaults.screencapture.location = "~/Pictures/screenshots";

  # Nix settings (Determinate manages Nix itself)
  nix.enable = false;

  # Users
  users.users.yoptabyte = {
    name = "yoptabyte";
    home = "/Users/yoptabyte";
    shell = pkgs.nushell;
  };

  system.primaryUser = "yoptabyte";

  # Homebrew
  homebrew.enable = true;
  homebrew.brews = [ "coreutils" "brightness" ];
  homebrew.casks = [ "ghostty" "vlc" ];
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.onActivation.autoUpdate = false;

  # State version
  system.stateVersion = 5;
}
