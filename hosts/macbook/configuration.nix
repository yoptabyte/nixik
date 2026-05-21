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
    inputs.nixvim.result.nixDarwinModules.nixvim
    ../../modules/home/nixvim.nix

    # Hjem nix-darwin module
    (import "${inputs.hjem.src}/modules/nix-darwin").default
  ];

  nixpkgs.config.allowUnfree = true;

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
  homebrew.brews = [ ];
  homebrew.casks = [ "ghostty" ];
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.onActivation.autoUpdate = false;

  # Emacs launchd service
  launchd.user.agents.emacs = {
    command = "${lib.getExe myEmacs} --fg-daemon";
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
  };

  # AeroSpace launchd service (tiling WM for macOS)
  launchd.user.agents.aerospace = {
    command = "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
  };

  # Hjem home configuration
  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.result.hjemModules.default
    ];
    users.yoptabyte = {
      enable = true;
      files = {
        # AeroSpace config (version 0.20+)
        ".config/aerospace/aerospace.toml".text = ''
          config-version = 2

          after-startup-command = []
          default-root-container-layout = "tiles"
          enable-normalization-flatten-containers = true
          enable-normalization-opposite-orientation-for-nested-containers = true

          [gaps]
          inner.horizontal = 8
          inner.vertical = 8
          outer.left = 8
          outer.bottom = 8
          outer.top = 8
          outer.right = 8

          [mode.main.binding]
          alt-h = "focus left"
          alt-j = "focus down"
          alt-k = "focus up"
          alt-l = "focus right"
          alt-shift-h = "move left"
          alt-shift-j = "move down"
          alt-shift-k = "move up"
          alt-shift-l = "move right"
          alt-1 = "workspace 1"
          alt-2 = "workspace 2"
          alt-3 = "workspace 3"
          alt-4 = "workspace 4"
          alt-5 = "workspace 5"
          alt-6 = "workspace 6"
          alt-7 = "workspace 7"
          alt-8 = "workspace 8"
          alt-9 = "workspace 9"
          alt-shift-1 = "move-node-to-workspace 1"
          alt-shift-2 = "move-node-to-workspace 2"
          alt-shift-3 = "move-node-to-workspace 3"
          alt-shift-4 = "move-node-to-workspace 4"
          alt-shift-5 = "move-node-to-workspace 5"
          alt-shift-6 = "move-node-to-workspace 6"
          alt-shift-7 = "move-node-to-workspace 7"
          alt-shift-8 = "move-node-to-workspace 8"
          alt-shift-9 = "move-node-to-workspace 9"
          alt-tab = "workspace-back-and-forth"
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next"
          alt-slash = "fullscreen"
          alt-space = "layout floating tiling"
          alt-r = "reload-config"
        '';

        # Ghostty config
        ".config/ghostty/config".text = ''
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

        # Git config
        ".gitconfig".text = ''
          [user]
          	name = yoptabyte
          	email = telinnikolai@gmail.com
          [init]
          	defaultBranch = main
          [core]
          	editor = nvim
          [delta]
          	enable = true
          	line-numbers = true
          	side-by-side = true
          [filter "lfs"]
          	clean = git-lfs clean -- %f
          	smudge = git-lfs smudge -- %f
          	process = git-lfs filter-process
          	required = true
        '';

        # Emacs init.el
        ".emacs.d/init.el".source = ../../modules/shared/emacs-init.el;

        # Emacs theme
        ".emacs.d/themes/k380-graphite-theme.el".source = ../../modules/home/files/k380-graphite-theme.el;
      };

      packages = lib.filter (p: p != null) ((import ../../modules/shared/home-packages.nix { inherit pkgs; }) ++ [ myEmacs pkgs.aerospace pkgs.git-lfs ]);
    };
  };

  # State version
  system.stateVersion = 5;
}
