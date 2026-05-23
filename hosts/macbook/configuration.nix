{ config, lib, pkgs, inputs, ... }:
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
  homebrew.brews = [ "coreutils" "brightness" ];
  homebrew.casks = [ "ghostty" ];
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.onActivation.autoUpdate = false;

  # AeroSpace launchd service (tiling WM for macOS)
  launchd.user.agents.aerospace = {
    command = "/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
  };

  # SketchyBar launchd service — manual plist (nix-darwin's exec wrapper breaks two-step startup)

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
          # Reference: https://github.com/i3/i3/blob/next/etc/config

          config-version = 2

          # In i3, all workspaces are phantom
          persistent-workspaces = []

          # i3 doesn't have "normalizations" feature that why we disable them here.
          # But the feature is very helpful.
          # Normalizations eliminate all sorts of weird tree configurations that don't make sense.
          # Give normalizations a chance and enable them back.
          enable-normalization-flatten-containers = false
          enable-normalization-opposite-orientation-for-nested-containers = false

          # Mouse follows focus when focused monitor changes
          on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

          [mode.main.binding]
              alt-enter = "exec-and-forget osascript -e 'tell application \"Ghostty\"\n    activate\nend tell'"

              alt-h = 'focus --boundaries-action wrap-around-the-workspace left'
              alt-j = 'focus --boundaries-action wrap-around-the-workspace down'
              alt-k = 'focus --boundaries-action wrap-around-the-workspace up'
              alt-l = 'focus --boundaries-action wrap-around-the-workspace right'

              alt-shift-h = 'move left'
              alt-shift-j = 'move down'
              alt-shift-k = 'move up'
              alt-shift-l = 'move right'

              alt-b = 'split horizontal'
              alt-v = 'split vertical'

              alt-q = 'close'

              alt-d = "exec-and-forget osascript -e 'tell application \"System Events\" to keystroke space using command down'"

              alt-f = 'fullscreen'

              alt-s = 'layout v_accordion'
              alt-w = 'layout h_accordion'
              alt-e = 'layout tiles horizontal vertical'

              alt-shift-space = 'layout floating tiling'

              alt-1 = 'workspace 1'
              alt-2 = 'workspace 2'
              alt-3 = 'workspace 3'
              alt-4 = 'workspace 4'
              alt-5 = 'workspace 5'
              alt-6 = 'workspace 6'
              alt-7 = 'workspace 7'
              alt-8 = 'workspace 8'
              alt-9 = 'workspace 9'
              alt-0 = 'workspace 10'

              alt-shift-1 = 'move-node-to-workspace 1'
              alt-shift-2 = 'move-node-to-workspace 2'
              alt-shift-3 = 'move-node-to-workspace 3'
              alt-shift-4 = 'move-node-to-workspace 4'
              alt-shift-5 = 'move-node-to-workspace 5'
              alt-shift-6 = 'move-node-to-workspace 6'
              alt-shift-7 = 'move-node-to-workspace 7'
              alt-shift-8 = 'move-node-to-workspace 8'
              alt-shift-9 = 'move-node-to-workspace 9'
              alt-shift-0 = 'move-node-to-workspace 10'

              alt-shift-c = 'reload-config'

              alt-shift-x = "exec-and-forget osascript -e 'tell application \"System Events\" to key code 12 using {control down, command down}'"

              alt-r = 'mode resize'

          [mode.resize.binding]
              h = 'resize width -50'
              j = 'resize height +50'
              k = 'resize height -50'
              l = 'resize width +50'
              enter = 'mode main'
              esc = 'mode main'
        '';

        # SketchyBar config — i3statusbar-rs replica
        ".config/sketchybar/sketchybarrc".text = ''
          export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

          PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

          # Bar (i3statusbar-rs theme: bg #282828, fg #f0c040)
          sketchybar --bar position=top height=36 blur_radius=0 color=0xff282828 topmost=on

          # Defaults
          sketchybar --default \
            padding_left=10 \
            padding_right=12 \
            icon.font="ZedMono Nerd Font:Bold:14.0" \
            label.font="ZedMono Nerd Font:Regular:12.0" \
            icon.color=0xfff0c040 \
            label.color=0xfff0c040 \
            background.color=0x00000000

          # Left: Spaces (AeroSpace workspaces)
          for i in $(seq 1 10); do
            sketchybar --add item space."$i" left \
              --set space."$i" icon="$i" \
                icon.padding_left=10 icon.padding_right=10 \
                icon.color=0xffc8c8c0 \
                icon.highlight_color=0xfff0c040 \
                icon.highlight=off \
                label.drawing=off \
                background.color=0xff3a3a38 \
                background.corner_radius=4 \
                background.height=24 \
                background.padding_left=2 \
                background.padding_right=2 \
                background.drawing=on \
                script="$PLUGIN_DIR/space.sh" \
                click_script="aerospace workspace $i"
          done
          # Hidden monitor to poll AeroSpace focused workspace every second
          sketchybar --add item space_monitor left \
            --set space_monitor drawing=off update_freq=1 \
              script="$PLUGIN_DIR/space.sh"

          # Separator
          sketchybar --add item separator left \
            --set separator icon= label.drawing=off width=10

          # Right: Front app
          sketchybar --add item front_app right \
            --set front_app icon.drawing=off \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/front_app.sh" \
            --subscribe front_app front_app_switched

          # Right: CPU
          sketchybar --add item cpu right \
            --set cpu update_freq=2 \
              icon= icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/cpu.sh"

          # Right: Memory
          sketchybar --add item memory right \
            --set memory update_freq=5 \
              icon= icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/memory.sh"

          # Right: Disk
          sketchybar --add item disk right \
            --set disk update_freq=30 \
              icon= icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/disk.sh"

          # Right: Volume
          sketchybar --add item volume right \
            --set volume icon=󰕾 icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/volume.sh" \
            --subscribe volume volume_change

          # Right: Battery
          sketchybar --add item battery right \
            --set battery update_freq=120 \
              icon=󰁹 icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/battery.sh" \
            --subscribe battery system_woke power_source_change

          # Right: Keyboard layout
          sketchybar --add item keyboard_layout right \
            --set keyboard_layout update_freq=1 \
              icon= icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/keyboard_layout.sh"

          # Right: Network
          sketchybar --add item network right \
            --set network update_freq=2 \
              icon=󰖩 icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/network.sh"

          # Right: Clock
          sketchybar --add item clock right \
            --set clock update_freq=10 \
              icon= icon.color=0xfff0c040 \
              label.color=0xfff0c040 \
              script="$PLUGIN_DIR/clock.sh"

          sketchybar --update
        '';

        ".config/sketchybar/plugins/space.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
            EXISTING=$(aerospace list-workspaces --all 2>/dev/null || echo "1 2 3 4 5 6 7 8 9 10")
            for sid in $(seq 1 10); do
              if echo "$EXISTING" | grep -wq "$sid"; then
                sketchybar --set space."$sid" drawing=on
                if [ "$sid" = "$FOCUSED" ]; then
                  sketchybar --set space."$sid" icon.highlight=on
                else
                  sketchybar --set space."$sid" icon.highlight=off
                fi
              else
                sketchybar --set space."$sid" drawing=off
              fi
            done
          '';
        };

        ".config/sketchybar/plugins/front_app.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            sketchybar --set front_app label="$INFO"
          '';
        };

        ".config/sketchybar/plugins/cpu.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
            CPU_INFO=$(ps -eo pcpu,user)
            CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
            CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
            CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"
            sketchybar --set $NAME label="''${CPU_PERCENT}%"
          '';
        };

        ".config/sketchybar/plugins/memory.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            MEM_PCT=$(memory_pressure | awk '/System-wide memory free percentage:/ {print int(100 - $5)}')
            sketchybar --set $NAME label="''${MEM_PCT}%"
          '';
        };

        ".config/sketchybar/plugins/disk.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            DISK_INFO=$(df -H / | tail -1)
            AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
            sketchybar --set $NAME label="''${AVAIL}B"
          '';
        };

        ".config/sketchybar/plugins/volume.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            if [ "$SENDER" = "volume_change" ]; then
              VOLUME=$INFO
            else
              VOLUME=$(osascript -e 'output volume of (get volume settings)')
            fi
            if [ "$VOLUME" = "0" ]; then
              ICON="󰝟"
            elif [ "$VOLUME" -lt 33 ]; then
              ICON="󰕿"
            elif [ "$VOLUME" -lt 67 ]; then
              ICON="󰖀"
            else
              ICON="󰕾"
            fi
            sketchybar --set $NAME icon="$ICON" label="''${VOLUME}%"
          '';
        };

        ".config/sketchybar/plugins/clock.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            sketchybar --set clock label="$(date '+%a %d/%m %R')"
          '';
        };

        ".config/sketchybar/plugins/battery.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            PERCENTAGE=$(pmset -g batt | grep -Eo '\d+%' | cut -d% -f1)
            CHARGING=$(pmset -g batt | grep 'AC Power')
            if [ "$PERCENTAGE" = "" ]; then
              exit 0
            fi
            if [ "$CHARGING" != "" ]; then
              ICON=""
            elif [ "$PERCENTAGE" -gt 80 ]; then
              ICON=""
            elif [ "$PERCENTAGE" -gt 60 ]; then
              ICON=""
            elif [ "$PERCENTAGE" -gt 40 ]; then
              ICON=""
            elif [ "$PERCENTAGE" -gt 20 ]; then
              ICON=""
            else
              ICON=""
            fi
            sketchybar --set battery icon="$ICON" label="$PERCENTAGE%"
          '';
        };

        ".config/sketchybar/plugins/keyboard_layout.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            LAYOUT=$(defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null | plutil -convert json -o - - 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0].get('KeyboardLayout Name', d[0].get('Input Source', '??')))" 2>/dev/null)
            case "$LAYOUT" in
              *Russian*) LABEL="RU" ;;
              *US*|*English*|*ABC*) LABEL="US" ;;
              *) LABEL="''${LAYOUT:0:2}" ;;
            esac
            sketchybar --set $NAME label="$LABEL"
          '';
        };

        ".config/sketchybar/plugins/network.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            export PATH="/etc/profiles/per-user/yoptabyte/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            INTERFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
            if [ -z "$INTERFACE" ]; then
              sketchybar --set $NAME label="—"
              exit 0
            fi
            CACHE="/tmp/sketchybar_net_''${INTERFACE}"
            read RX_NOW TX_NOW <<< $(netstat -ib | grep -E "^\w*''${INTERFACE}" | head -1 | awk '{print $7, $10}')
            if [ -f "$CACHE" ]; then
              source "$CACHE"
              if [ -n "$PREV_RX" ] && [ -n "$PREV_TX" ]; then
                RX_DIFF=$((RX_NOW - PREV_RX))
                TX_DIFF=$((TX_NOW - PREV_TX))
                RX_KB=$((RX_DIFF / 2048))
                TX_KB=$((TX_DIFF / 2048))
                sketchybar --set $NAME label="↓''${RX_KB}↑''${TX_KB}K"
              fi
            fi
            echo "PREV_RX=$RX_NOW" > "$CACHE"
            echo "PREV_TX=$TX_NOW" >> "$CACHE"
          '';
        };

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

          # Ctrl+1..Ctrl+0 → F5-F12 for tmux window selection
          keybind = ctrl+1=csi:15~
          keybind = ctrl+2=csi:17~
          keybind = ctrl+3=csi:18~
          keybind = ctrl+4=csi:19~
          keybind = ctrl+5=csi:20~
          keybind = ctrl+6=csi:21~
          keybind = ctrl+7=csi:23~
          keybind = ctrl+8=csi:24~
          keybind = ctrl+9=csi:23;2~
          keybind = ctrl+0=csi:24;2~
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

        # Tmux config
        ".config/tmux/tmux.conf".text = ''
          set -g status-position bottom
          set -g status-bg '#302e26'
          set -g status-fg '#888882'
          set -g status-left "#[fg=#f0c040]░▒▓#[fg=#1c1c1c,bg=#f0c040] #S #[fg=#f0c040,bg=#302e26]▓▒░"
          set -g status-right "#[fg=#f0c040]░▒▓#[fg=#1c1c1c,bg=#f0c040] %I:%M %p #[fg=#f0c040,bg=#302e26]▓▒░"
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

          bind-key -n C-r source-file ~/.config/tmux/tmux.conf \; display-message "Tmux config reloaded"
          bind-key -n C-s command-prompt -p "New session name:" "new-session -s '%%'"
          bind-key -n C-t choose-tree -Zw
          bind-key -n "F5" select-window -t 1
          bind-key -n "F6" select-window -t 2
          bind-key -n "F7" select-window -t 3
          bind-key -n "F8" select-window -t 4
          bind-key -n "F9" select-window -t 5
          bind-key -n "F10" select-window -t 6
          bind-key -n "F11" select-window -t 7
          bind-key -n "F12" select-window -t 8
          bind-key -n "S-F11" select-window -t 9
          bind-key -n "S-F12" select-window -t 10

          bind-key -n C-Left select-pane -L
          bind-key -n C-Down select-pane -D
          bind-key -n C-Up select-pane -U
          bind-key -n C-Right select-pane -R

          bind-key -n C-S-Left resize-pane -L 5
          bind-key -n C-S-Down resize-pane -D 5
          bind-key -n C-S-Up resize-pane -U 5
          bind-key -n C-S-Right resize-pane -R 5

          bind-key -n C-h split-window -v -c "#{pane_current_path}"
          bind-key -n C-v split-window -h -c "#{pane_current_path}"
          bind-key -n C-Enter new-window -c "#{pane_current_path}"

          bind-key -n C-c kill-pane
          bind-key -n C-q kill-window
          bind-key -n C-d detach-client
          bind-key -n C-x confirm-before -p "Kill session #S? (y/n)" kill-session

          bind-key -T copy-mode-vi C-/ send-keys -X search-forward
          bind-key -T copy-mode-vi C-? send-keys -X search-backward

          if-shell '[ -f ~/.config/tmux/utility.conf ]' 'source-file ~/.config/tmux/utility.conf'

          bind -r g display-popup -d '#{pane_current_path}' -w80% -h80% -E lazygit

          bind -r y run-shell 'SESSION="claude-$(echo #{pane_current_path} | md5 -r | cut -c1-8)"; tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION" -c "#{pane_current_path}" "claude"; tmux display-popup -w80% -h80% -E "tmux attach-session -t $SESSION"'

          bind -r o run-shell 'SESSION="opencode-$(echo #{pane_current_path} | md5 -r | cut -c1-8)"; tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION" -c "#{pane_current_path}" "opencode"; tmux display-popup -w80% -h80% -E "tmux attach-session -t $SESSION"'

          bind -r x run-shell 'SESSION="codex-$(echo #{pane_current_path} | md5 -r | cut -c1-8)"; tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION" -c "#{pane_current_path}" "codex"; tmux display-popup -w80% -h80% -E "tmux attach-session -t $SESSION"'
        '';

        # Nushell config
        "Library/Application Support/nushell/config.nu".text = ''
          # Nix profile paths (macOS doesn't set these globally like NixOS)
          $env.PATH = ($env.PATH | prepend "/etc/profiles/per-user/yoptabyte/bin" | prepend "/run/current-system/sw/bin")

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
            { run = "open %s", orphan = true, desc = "View document" },
          ]
          img = [
            { run = "open %s", orphan = true, desc = "View images" },
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

      };

      packages = lib.filter (p: p != null) ((import ../../modules/shared/home-packages.nix { inherit pkgs; }) ++ [ pkgs.aerospace pkgs.sketchybar pkgs.git-lfs config.programs.nixvim.finalPackage ]);
    };
  };

  # Symlink AeroSpace.app to /Applications for stable Accessibility permission path
  system.activationScripts.aerospace-symlink = {
    text = ''
      ln -sf ${pkgs.aerospace}/Applications/AeroSpace.app /Applications/AeroSpace.app
    '';
  };

  # Disable Ghostty auto-launch
  system.activationScripts.ghostty-no-autostart = {
    text = ''
      sudo -u yoptabyte /bin/sh -c '
        defaults write com.mitchellh.ghostty ApplePersistence -bool false 2>/dev/null
        defaults write com.mitchellh.ghostty NSQuitAlwaysKeepsWindows -bool false 2>/dev/null
      '
    '';
  };

  # Reload sketchybar launchd after activation (writes real plist so it survives reboot)
  system.activationScripts.sketchybar-launchd = let
    sketchybarPlist = pkgs.writeText "org.nixos.sketchybar.plist" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>KeepAlive</key>
          <true/>
          <key>Label</key>
          <string>org.nixos.sketchybar</string>
          <key>ProgramArguments</key>
          <array>
              <string>/bin/sh</string>
              <string>-c</string>
              <string>/bin/wait4path /nix/store &amp;&amp; ${lib.getExe pkgs.sketchybar} &amp; sleep 2 &amp;&amp; /bin/bash $HOME/.config/sketchybar/sketchybarrc &amp;&amp; wait</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
      </dict>
      </plist>
    '';
  in {
    text = ''
      sudo -u yoptabyte /bin/sh -c '
        launchctl bootout gui/$(id -u)/org.nixos.sketchybar 2>/dev/null
        sleep 1
        cp ${sketchybarPlist} $HOME/Library/LaunchAgents/org.nixos.sketchybar.plist
        launchctl enable gui/$(id -u)/org.nixos.sketchybar
        launchctl bootstrap gui/$(id -u) $HOME/Library/LaunchAgents/org.nixos.sketchybar.plist
        echo "sketchybar: launchd reloaded"
      '
    '';
  };

  # State version
  system.stateVersion = 5;
}
