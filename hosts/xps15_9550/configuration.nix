{ config, lib, pkgs, inputs, ... }:
let
  vicinaePkg = pkgs.vicinae;
in

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/nix-settings.nix
    ../../modules/nixos/llm-agents.nix
    ../../modules/nixos/browsers.nix
    ../../modules/nixos/terminal.nix
    ../../modules/nixos/productivity.nix
    ../../modules/nixos/emacs.nix
    ../../modules/nixos/creative.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/social.nix
    ../../modules/nixos/desktop/sway.nix

    # Hjem home manager module
    (import "${inputs.hjem.src}/modules/nixos").default

    # Nixvim NixOS module
    inputs.nixvim.result.nixosModules.nixvim
    ../../modules/home/nixvim.nix

    # XLibre overlay modules
    inputs.xlibre-overlay.result.nixosModules.overlay-xlibre-xserver
    inputs.xlibre-overlay.result.nixosModules.overlay-all-xlibre-drivers
    inputs.xlibre-overlay.result.nixosModules.nvidia-ignore-ABI
  ];

  # Fonts
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [ nerd-fonts.zed-mono nerd-fonts.symbols-only ];

  # Hostname
  networking.hostName = "xps15";

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
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # NetworkManager
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  # DNS servers (Google + Cloudflare)
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  # X11
  services.xserver.enable = true;
  services.displayManager.ly.enable = lib.mkForce true;
  services.displayManager.ly.settings = {
    load = false;
    save = false;
  };
  services.displayManager.defaultSession = "sway";

  # Keyboard layout - US + RU with Caps Lock switching
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:caps_toggle";

  # NVIDIA PRIME offloading
  hardware.nvidia.prime = {
    offload.enable = true;
    nvidiaBusId = "PCI:2:0:0";
    intelBusId = "PCI:1:0:0";
  };

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

  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  # Vicinae systemd user service
  systemd.user.services.vicinae = {
    description = "Vicinae server daemon";
    documentation = [ "https://docs.vicinae.com" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe vicinaePkg} server --replace";
      Restart = "always";
      RestartSec = 5;
      KillMode = "process";
      PassEnvironment = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "XDG_RUNTIME_DIR"
        "DBUS_SESSION_BUS_ADDRESS"
      ];
      Environment = [
        "PATH=/home/yoptabyte/.local/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:${lib.makeBinPath [ pkgs.thunar pkgs.pavucontrol ]}"
        "VICINAE_OVERRIDES=/home/yoptabyte/.config/vicinae/nix.json"
      ];
    };
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
      # Git config
      ".config/git/config".text = ''
        [user]
          name = yoptabyte
          email = telinnikolai@gmail.com
        [core]
          editor = nvim
        [init]
          defaultBranch = main
        [delta]
          enable = true
          line-numbers = true
          side-by-side = true
      '';

      # Jujutsu config
      ".config/jj/config.toml".text = ''
        [user]
        name = "yoptabyte"
        email = "yoptabyte@example.com"

        [ui]
        default-command = "log"
        pager = "less -FRX"

        [signing]
        backend = "ssh"
        sign-all = true

        [git]
        push-bookmark-prefix = "yoptabyte/push-"
      '';

      # Ghostty config
      ".config/ghostty/config".text = ''
        font-family = ZedMono Nerd Font
        font-size = 11
        background = 28261F
        foreground = c8c8c0
        background-opacity = 1.0
        background-blur = true
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

      # Tmux config
      ".config/tmux/tmux.conf".text = ''
        set -g status-position bottom
        set -g status-bg '#302e26'
        set -g status-fg '#888882'
        set -g status-left "#[fg=#f0c040]░▒▓#[fg=#1c1c1c,bg=#f0c040] #S #[fg=#f0c040,bg=#302e26]▓▒░"
        set -g status-right "#[fg=#f0c040]░▒▓#[fg=#1c1c1c,bg=#f0c040] 󰁹 #(cat /sys/class/power_supply/BAT0/capacity)%% | %I:%M %p #[fg=#f0c040,bg=#302e26]▓▒░"
        set -g status-justify centre

        set -g pane-border-style 'fg=#3a3a38'
        set -g pane-active-border-style 'fg=#f0c040'

        set -g window-status-current-format "#[fg=#f0c040]░▒▓#[fg=#1c1c1c,bg=#f0c040] #I:#W #[fg=#f0c040,bg=#302e26]▓▒░"
        set -g window-status-format "#[fg=#555550]░▒▓#[fg=#888882,bg=#555550] #I:#W #[fg=#555550,bg=#302e26]▓▒░"

        set -g message-style 'fg=#c8c8c0,bg=default'
        set -g mode-style 'fg=#1c1c1c,bg=#f0c040'

        set -g display-panes-active-colour '#f0c040'
        set -g display-panes-colour '#2b2b2b'

        set -g mouse on
        set -g base-index 1
        set -g pane-base-index 1
        set -g renumber-windows on
        set -g set-clipboard on

        setw -g mode-keys vi
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        bind c new-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"

        bind-key -n M-r source-file ~/.config/tmux/tmux.conf \; display-message "Tmux config reloaded"
        bind-key -n M-s command-prompt -p "New session name:" "new-session -s '%%'"
        bind-key -n M-t choose-tree -Zw
        bind-key -n M-1 select-window -t 1
        bind-key -n M-2 select-window -t 2
        bind-key -n M-3 select-window -t 3
        bind-key -n M-4 select-window -t 4
        bind-key -n M-5 select-window -t 5
        bind-key -n M-6 select-window -t 6
        bind-key -n M-7 select-window -t 7
        bind-key -n M-8 select-window -t 8
        bind-key -n M-9 select-window -t 9
        bind-key -n M-0 select-window -t 10

        bind-key -n M-Left select-pane -L
        bind-key -n M-Down select-pane -D
        bind-key -n M-Up select-pane -U
        bind-key -n M-Right select-pane -R

        bind-key -n M-S-Left resize-pane -L 5
        bind-key -n M-S-Down resize-pane -D 5
        bind-key -n M-S-Up resize-pane -U 5
        bind-key -n M-S-Right resize-pane -R 5

        bind-key -n M-h split-window -v -c "#{pane_current_path}"
        bind-key -n M-v split-window -h -c "#{pane_current_path}"
        bind-key -n M-Enter new-window -c "#{pane_current_path}"

        bind-key -n M-c kill-pane
        bind-key -n M-q kill-window
        bind-key -n M-d detach-client
        bind-key -n M-x confirm-before -p "Kill session #S? (y/n)" kill-session

        bind-key -T copy-mode-vi M-/ send-keys -X search-forward
        bind-key -T copy-mode-vi M-? send-keys -X search-backward

        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'

        if-shell '[ -f ~/.config/tmux/utility.conf ]' 'source-file ~/.config/tmux/utility.conf'

        bind -r g display-popup -d '#{pane_current_path}' -w80% -h80% -E lazygit

        bind -r y run-shell 'SESSION="claude-$(echo #{pane_current_path} | md5sum | cut -c1-8)"; tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION" -c "#{pane_current_path}" "claude"; tmux display-popup -w80% -h80% -E "tmux attach-session -t $SESSION"'

        bind -r o run-shell 'SESSION="opencode-$(echo #{pane_current_path} | md5sum | cut -c1-8)"; tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION" -c "#{pane_current_path}" "opencode"; tmux display-popup -w80% -h80% -E "tmux attach-session -t $SESSION"'

        bind -r x run-shell 'SESSION="codex-$(echo #{pane_current_path} | md5sum | cut -c1-8)"; tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION" -c "#{pane_current_path}" "codex"; tmux display-popup -w80% -h80% -E "tmux attach-session -t $SESSION"'
      '';

      # Nushell config
      ".config/nushell/config.nu".text = ''
        $env.config.show_banner = false
        $env.config.table.mode = "rounded"
        $env.config.history.file_format = "sqlite"

        alias em = emacsclient -c -n
        alias em-kill = emacsclient -e '(kill-emacs)'

        alias g    = git
        alias gs   = git status
        alias gss  = git status --short
        alias ga   = git add
        alias gaa  = git add --all
        alias gc   = git commit
        alias gcm  = git commit -m
        alias gco  = git checkout
        alias gsw  = git switch
        alias gb   = git branch
        alias gba  = git branch --all
        alias gl   = git log --oneline --graph --decorate
        alias gd   = git diff
        alias gds  = git diff --staged
        alias gp   = git push
        alias gpl  = git pull
        alias gf   = git fetch --all
        alias gst  = git stash
        alias gstp = git stash pop
        alias tn = tmux new -A -s

        def gcq [msg: string] {
            git add --all
            git commit -m $msg
        }

        $env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "starship.toml")
        $env.PROMPT_COMMAND = {|| starship prompt }
      '';

      # Starship config
      ".config/starship.toml".source = ../../modules/home/files/starship.toml;

      # Yazi config
      ".config/yazi/yazi.toml".text = ''
        [opener]
        edit = [
          { run = "nvim %s", block = true, desc = "Edit in Neovim" },
        ]
        doc = [
          { run = "zathura %s", orphan = true, desc = "View document" },
        ]
        img = [
          { run = "nsxiv %s", orphan = true, desc = "View images" },
        ]
        extract = [
          { run = "unar %s", block = true, desc = "Extract archive" },
        ]

        [open]
        rules = [
          { url = "*.nix", use = "edit" },
          { url = "*.rs",  use = "edit" },
          { url = "*.py",  use = "edit" },
          { url = "*.ts",  use = "edit" },
          { url = "*.tsx", use = "edit" },
          { url = "*.js",  use = "edit" },
          { url = "*.jsx", use = "edit" },
          { url = "*.lua", use = "edit" },
          { url = "*.md",  use = "edit" },
          { url = "*.txt", use = "edit" },
          { mime = "application/pdf", use = "doc" },
          { url = "*.epub", use = "doc" },
          { url = "*.djvu", use = "doc" },
          { mime = "image/*", use = "img" },
          { mime = "application/*zip", use = "extract" },
          { mime = "application/x-7z-compressed", use = "extract" },
          { mime = "application/x-rar", use = "extract" },
          { mime = "application/x-tar", use = "extract" },
          { mime = "application/gzip", use = "extract" },
          { mime = "application/x-bzip2", use = "extract" },
          { mime = "application/x-xz", use = "extract" },
        ]
      '';

      ".config/yazi/keymap.toml".text = ''
        [mgr]
        prepend_keymap = [
          { on = [ "c", "z" ], run = "shell 'zip -r archive.zip %s' --interactive --confirm", desc = "Create zip archive" },
          { on = [ "c", "7" ], run = "shell '7z a archive.7z %s' --interactive --confirm", desc = "Create 7z archive" },
          { on = [ "x", "z" ], run = "shell 'ripunzip unzip-file %s' --confirm", desc = "Extract zip with ripunzip" },
          { on = [ "x", "a" ], run = "shell 'unar %s' --confirm", desc = "Extract archive with unar" },
        ]
      '';

      # i3status-rust config
      ".config/i3status-rust/config.toml".text = ''
        [theme]
        theme = "plain"
        [theme.overrides]
        idle_bg = "#282828"
        idle_fg = "#f0c040"
        info_bg = "#282828"
        info_fg = "#f0c040"
        good_bg = "#282828"
        good_fg = "#f0c040"
        warning_bg = "#282828"
        warning_fg = "#e8a020"
        critical_bg = "#282828"
        critical_fg = "#fb4934"
        separator_bg = "#282828"
        separator_fg = "#f0c040"

        [icons]
        icons = "material-nf"

        [[block]]
        block = "cpu"
        interval = 1

        [[block]]
        block = "memory"
        format = " $icon $mem_used_percents "

        [[block]]
        block = "disk_space"
        path = "/"
        info_type = "available"
        alert_unit = "GB"
        interval = 20
        warning = 20.0
        alert = 10.0

        [[block]]
        block = "sound"
        [[block.click]]
        button = "left"
        cmd = "pavucontrol"

        [[block]]
        block = "backlight"

        [[block]]
        block = "battery"
        format = " $icon $percentage "

        [[block]]
        block = "time"
        interval = 60
        format = " $timestamp.datetime(f:'%a %d/%m %R') "

        [[block]]
        block = "keyboard_layout"
        driver = "sway"
        format = " $layout "
        [block.mappings]
        "English (N/A)" = "US"
        "Russian (N/A)" = "RU"
        "English (US)" = "US"
        "Russian (RU)" = "RU"

        [[block]]
        block = "net"
        format = " $icon ^icon_net_down $speed_down.eng(prefix:K) ^icon_net_up $speed_up.eng(prefix:K) "
      '';

      # Sway config
      ".config/sway/config".source = ../../modules/home/files/sway-config;

      # Vicinae launcher wrapper
      ".local/bin/vicinae-launcher" = {
        executable = true;
        source = ../../modules/home/files/vicinae-launcher;
      };

      # Vesktop bootstrap
      ".local/bin/vesktop-bootstrap" = {
        executable = true;
        source = ../../modules/home/files/vesktop-bootstrap;
      };

      # Vesktop desktop entry
      ".local/share/applications/vesktop.desktop".text = ''
        [Desktop Entry]
        Categories=Network;InstantMessaging;Chat
        Exec=/home/yoptabyte/.local/bin/vesktop-bootstrap %U
        GenericName=Internet Messenger
        Icon=vesktop
        Keywords=discord;vencord;electron;chat
        Name=Vesktop
        StartupWMClass=Vesktop
        Type=Application
        Version=1.5
      '';

      # Autostart entries
      ".config/autostart/com.mitchellh.ghostty.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Ghostty
        Hidden=true
      '';

      ".config/autostart/xcape-vicinae.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Version=1.0
        Name=Xcape Vicinae Binding
        Comment=Map a tapped Super key to Menu for Vicinae
        Exec=${pkgs.xcape}/bin/xcape -e 'Super_L=Menu;Super_R=Menu'
        OnlyShowIn=sway;
        StartupNotify=false
        Terminal=false
      '';

      # Vicinae settings
      ".config/vicinae/nix.json".source = ../../modules/home/files/vicinae-settings.json;

      # Vicinae themes
      ".config/vicinae/themes/amber-night.toml".source = ../../modules/home/files/vicinae-theme-amber-night.toml;
      ".config/vicinae/themes/amber-day.toml".source = ../../modules/home/files/vicinae-theme-amber-day.toml;
      ".config/vicinae/themes/ghostty-night.toml".source = ../../modules/home/files/vicinae-theme-ghostty-night.toml;
    };

    packages = (import ../../modules/shared/home-packages.nix { inherit pkgs; }) ++ (with pkgs; [
      # Sway tools (Linux-specific)
      mako
      i3status-rust
      grim
      slurp
      wl-clipboard
      brightnessctl
      swaylock
      wmenu
      bluetui
      pulsemixer
      xcape

      # Linux-specific tools
      antigravity
      vicinaePkg
      pkgs.pulseaudio
    ]);
  };
};

  # State version
  system.stateVersion = "26.05";
}
