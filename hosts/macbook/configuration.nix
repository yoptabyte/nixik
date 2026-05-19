{ config, lib, pkgs, inputs, ... }:

let
  sharedPackages = import ../../modules/shared/home-packages.nix { inherit pkgs; };

  myEmacs = (pkgs.emacs30.pkgs.withPackages (epkgs: with epkgs; [
    vertico orderless marginalia consult which-key
    evil evil-collection general drag-stuff
    treemacs treemacs-evil treemacs-magit
    magit diff-hl
    doom-modeline nerd-icons nerd-icons-completion
    vterm
    nix-mode markdown-mode scala-mode
    treesit-grammars.with-all-grammars
    pdf-tools
  ]));
in

{
  imports = [
    # Nixvim
    inputs.nixvim.result.nixosModules.nixvim
    ../../modules/home/nixvim.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = sharedPackages ++ [ myEmacs ];

  # Fonts
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [ nerd-fonts.zed-mono nerd-fonts.symbols-only ];

  # Hostname
  networking.hostName = "yoptabyte-macbook";
  networking.computerName = "yoptabyte-macbook";

  # Timezone
  time.timeZone = "Europe/Lisbon";

  # Locale
  system.defaults.NSGlobalDomain.AppleLocale = "en_US@currency=EUR";
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

  # Nix settings
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "yoptabyte" "@admin" ];

  # Users
  users.users.yoptabyte = {
    name = "yoptabyte";
    home = "/Users/yoptabyte";
    shell = pkgs.nushell;
  };

  # Git
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "yoptabyte";
    userEmail = "telinnikolai@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      delta.enable = true;
      delta.line-numbers = true;
      delta.side-by-side = true;
    };
  };

  # Homebrew
  homebrew.enable = true;
  homebrew.brews = [ ];
  homebrew.casks = [ "firefox" ];
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.autoUpdate = false;

  # Emacs launchd service
  launchd.user.agents.emacs = {
    command = "${lib.getExe myEmacs} --fg-daemon";
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
  };

  # Ghostty config
  environment.etc."ghostty/config".text = ''
    font-family = ZedMono Nerd Font
    font-size = 11
    background = 28261F
    foreground = c8c8c0
    background-opacity = 1.0
    cursor-style = block
    cursor-style-blink = true
    cursor-color = f0c040
    cursor-text = 28261F
    selection-background = 3a3a38
    selection-foreground = c8c8c0
    window-padding-x = 10
    window-padding-y = 10
    window-decoration = false
    clipboard-read = allow
    clipboard-write = allow
    mouse-scroll-multiplier = 1
    scrollback-limit = 0
    palette = 0=#28261F
    palette = 1=#a8d8a0
    palette = 2=#e8a020
    palette = 3=#f0c040
    palette = 4=#888882
    palette = 5=#a8d8a0
    palette = 6=#e8a020
    palette = 7=#c8c8c0
    palette = 8=#3a3a38
    palette = 9=#a8d8a0
    palette = 10=#e8a020
    palette = 11=#f0c040
    palette = 12=#888882
    palette = 13=#a8d8a0
    palette = 14=#e8a020
    palette = 15=#c8c8c0
  '';

  # Emacs init.el
  environment.etc."emacs.d/init.el".source = ../../modules/shared/emacs-init.el;

  # Emacs theme
  environment.etc."emacs.d/themes/k380-graphite-theme.el".source = ../../modules/home/files/k380-graphite-theme.el;

  # Create symlinks from /etc to user home directory
  system.activationScripts.postActivation.text = ''
    USER_HOME=/Users/yoptabyte

    mkdir -p "$USER_HOME/.config/ghostty"
    mkdir -p "$USER_HOME/.emacs.d/themes"

    ln -sfn /etc/ghostty/config "$USER_HOME/.config/ghostty/config"
    ln -sfn /etc/emacs.d/init.el "$USER_HOME/.emacs.d/init.el"
    ln -sfn /etc/emacs.d/themes/k380-graphite-theme.el "$USER_HOME/.emacs.d/themes/k380-graphite-theme.el"

    chown -R yoptabyte:staff "$USER_HOME/.config/ghostty" "$USER_HOME/.emacs.d" 2>/dev/null || true
  '';

  # State version
  system.stateVersion = 5;
}
