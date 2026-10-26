{ config, lib, pkgs, inputs, ... }:
let
  omarchy = inputs.opinionated-nix.src;
  # Hyprlock uses a still frame from the animated desktop wallpaper.
  lockWallpaper = ../../../wallpapers/garden_rain.jpg;
  inherit (import ../../../packages/hyprland-plugins.nix { inherit pkgs lib inputs; }) hyprexpo phantomat;
  herdrVisualBlock = pkgs.callPackage ../../../packages/herdr.nix {};
  waybarStable = pkgs.callPackage ../../../packages/waybar.nix {};

in
{
  imports = [ ../herdr-telegram.nix ];
  programs.herdr-telegram = {
    enable = true;
    herdrPackage = herdrVisualBlock;
    users = [ "yoptabyte" ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  services.xserver.desktopManager.xterm.enable = lib.mkForce false;
  programs.foot.enable = lib.mkForce false;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
    config.common = {
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprlock = {};

  environment.systemPackages = with pkgs; [
    awww hypridle hyprlock hyprpolkitagent
    waybarStable mako herdrVisualBlock voxtype-vulkan hyprexpo phantomat
    wl-clipboard grim slurp brightnessctl libnotify pavucontrol
  ];

  systemd.user.services.waybar = {
    description = "Waybar for Hyprland";
    after = [ "graphical-session.target" ];
    requisite = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = lib.getExe waybarStable;
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  systemd.user.services.voxtype = {
    description = "Voxtype dictation daemon for Hyprland";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = [ pkgs.curl ];
    # Hybrid laptops enumerate Intel first. Restrict this service's Vulkan loader
    # to NVIDIA; Voxtype's vendor selector is not applied by its daemon command.
    environment = lib.optionalAttrs (config.hardware.nvidia.prime.offload.enable or false) {
      VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
    };
    serviceConfig = {
      ExecStartPre = "${lib.getExe pkgs.voxtype-vulkan} setup --download --model large-v3-turbo";
      ExecStart = "${lib.getExe pkgs.voxtype-vulkan} daemon";
      Restart = "on-failure";
      RestartSec = 60;
    };
  };

  hjem.users.yoptabyte.files = {
    # Avoid DMA-BUF negotiation failures when sharing on hybrid Intel/NVIDIA GPUs.
    ".config/hypr/xdph.conf".text = ''
      screencopy {
        force_shm = true
      }
    '';
    ".config/hypr/hyprland.lua".text = ''
      hl.permission({ binary = [[${lib.escapeRegex "${hyprexpo}/lib/libhyprexpo.so"}]], type = "plugin", mode = "allow" })
      hl.permission({ binary = [[${lib.escapeRegex "${phantomat}/lib/libspatialoverview.so"}]], type = "plugin", mode = "allow" })
      hl.plugin.load("${hyprexpo}/lib/libhyprexpo.so")
      ${builtins.readFile (omarchy + "/default/hypr/looknfeel.lua")}
      ${builtins.readFile ../../home/files/hyprland/hyprland.lua}
      ${lib.optionalString (config.networking.hostName == "xps15") (builtins.readFile ../../home/files/hyprland/hyprland-xps-monitors.lua)}
    '';
    ".local/bin/phantomat-workspace" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        set -eu

        hyprctl=${pkgs.hyprland}/bin/hyprctl
        jq=${lib.getExe pkgs.jq}
        flock=${pkgs.util-linux}/bin/flock
        hyprexpo=${hyprexpo}/lib/libhyprexpo.so
        phantomat=${phantomat}/lib/libspatialoverview.so

        state_dir="''${XDG_RUNTIME_DIR:?}/phantomat-''${HYPRLAND_INSTANCE_SIGNATURE:?}"
        mkdir -p "$state_dir"
        exec 9>"$state_dir/lock"
        "$flock" -x 9

        current_workspace() {
          "$hyprctl" -j activeworkspace | "$jq" -r '.id'
        }

        plugin_loaded() {
          "$hyprctl" plugin list | grep -Fq "Plugin $1 by "
        }

        restore_hyprexpo() {
          if ! plugin_loaded hyprexpo; then
            "$hyprctl" plugin load "$hyprexpo"
          fi
        }

        stop_canvas() {
          if plugin_loaded spatialoverview; then
            "$hyprctl" plugin unload "$phantomat"
          fi
          restore_hyprexpo
          rm -f "$state_dir/workspace"
          "$hyprctl" reload
        }

        if [ -f "$state_dir/workspace" ]; then
          if [ "''${1:-toggle}" = "navigate" ]; then
            "$hyprctl" dispatch 'hl.plugin.spatialoverview.overview("toggle")'
            exit 0
          fi
          if [ "''${1:-toggle}" = "leave" ]; then
            old_workspace=$(cat "$state_dir/workspace")
            [ "$(current_workspace)" != "$old_workspace" ] || exit 0
          fi
          stop_canvas
          exit 0
        fi

        [ "''${1:-toggle}" = "toggle" ] || exit 0
        workspace=$(current_workspace)
        if "$hyprctl" -j clients | "$jq" -e --argjson workspace "$workspace" \
          'any(.[]; .workspace.id == $workspace and (.grouped | length > 0))' >/dev/null; then
          ${pkgs.libnotify}/bin/notify-send "Phantomat" "Сначала убери группы окон на этом воркспейсе"
          exit 1
        fi
        if plugin_loaded spatialoverview; then
          echo "Phantomat is already loaded outside this toggle" >&2
          exit 1
        fi
        "$hyprctl" plugin unload "$hyprexpo"
        if ! "$hyprctl" plugin load "$phantomat"; then
          restore_hyprexpo || true
          "$hyprctl" reload || true
          exit 1
        fi
        if ! "$hyprctl" dispatch 'hl.plugin.spatialoverview.overview("scope")'; then
          "$hyprctl" plugin unload "$phantomat" || true
          restore_hyprexpo || true
          "$hyprctl" reload || true
          exit 1
        fi
        printf '%s\n' "$workspace" > "$state_dir/workspace"
      '';
    };
    ".config/hypr/wallpaper.gif".source = ../../../wallpapers/garden_rain.gif;
    ".local/bin/awww-wallpaper" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        for attempt in $(seq 1 50); do
          if ${lib.getExe pkgs.awww} query >/dev/null 2>&1; then
            exec ${lib.getExe pkgs.awww} img --resize stretch "$HOME/.config/hypr/wallpaper.gif"
          fi
          sleep 0.1
        done
        echo "awww daemon did not become ready" >&2
        exit 1
      '';
    };
    ".config/hypr/hypridle.conf".source = ../../home/files/hyprland/hypridle.conf;
    ".config/hypr/hyprlock.conf".text = ''
      background {
        monitor =
        path = ${lockWallpaper}
        blur_passes = 3
        blur_size = 5
      }
      general {
        hide_cursor = true
      }
      input-field {
        monitor =
        size = 320, 55
        outline_thickness = 2
        dots_center = true
        outer_color = rgb(d65d0e)
        inner_color = rgb(fbf1c7)
        font_color = rgb(3c3836)
        check_color = rgb(98971a)
        fail_color = rgb(cc241d)
        placeholder_text = Password
      }
      label {
        monitor =
        text = $TIME
        color = rgb(3c3836)
        font_size = 64
        font_family = ComicTrueMono Nerd Font Mono
        position = 0, 140
        halign = center
        valign = center
      }
    '';
    ".config/mako/config".source = ../../home/files/mako/mako-gruvbox-light;
    ".config/waybar/config.jsonc".source = ../../home/files/waybar/waybar-hyprland.jsonc;
    ".config/waybar/style.css".source = ../../home/files/waybar/waybar-gruvbox-light.css;
    # Herdr writes to config.toml, so it must be a writable copy. Clobbering
    # also replaces the symlink installed by the previous Hjem generation.
    ".config/herdr/config.toml" = {
      type = "copy";
      source = ../../home/files/herdr/herdr-config.toml;
      clobber = true;
      permissions = "0644";
    };
    ".config/voxtype/config.toml".source = ../../home/files/voxtype/voxtype-config.toml;
  };
}
