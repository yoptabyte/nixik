{ config, lib, pkgs, ... }:
let
  cfg = config.programs.herdr-telegram;
  pluginRoot = "${cfg.package}/${cfg.package.pluginRoot}";
  register = pkgs.writeShellScript "herdr-telegram-register" ''
    set -eu
    ${cfg.package}/bin/herdr-agent-integrations --herdr ${lib.getExe cfg.herdrPackage}
    ${lib.getExe cfg.herdrPackage} plugin link ${lib.escapeShellArg pluginRoot}

    # A running daemon must adopt the new package after a configuration switch.
    # A new account only receives the registration; setup remains in Herdr.
    plugin_state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/herdr/plugins/permgps.telegram-agents"
    if [ -s "$plugin_state_dir/daemon.pid" ]; then
      ${lib.getExe cfg.herdrPackage} plugin action invoke permgps.telegram-agents.restart
    fi
  '';
  server = pkgs.writeShellScript "herdr-server" ''
    export PATH="$HOME/.npm-global/bin:$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"
    exec ${lib.getExe cfg.herdrPackage} server
  '';
in
{
  options.programs.herdr-telegram = {
    enable = lib.mkEnableOption "the pinned Herdr Telegram plugin with complete replies";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../packages/herdr-telegram-agents.nix {};
      description = "Telegram plugin package, including its local reply patches.";
    };
    herdrPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.herdr;
      description = "Herdr used to register and run the plugin.";
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "User accounts receiving the plugin registration.";
    };
    server.enable = lib.mkEnableOption "a persistent headless Herdr server";
  };

  config = lib.mkIf cfg.enable {
    assertions = [ {
      assertion = cfg.users != [];
      message = "programs.herdr-telegram.users must name the accounts receiving the plugin.";
    } ];
    environment.systemPackages = [ cfg.package cfg.herdrPackage ];
    # A host bootstrapped without sudo uses marked user-unit symlinks.
    # Remove only those links when NixOS takes over on its next switch.
    system.activationScripts.herdr-telegram-bootstrap = {
      deps = [ "users" ];
      text = lib.concatMapStringsSep "\n" (user: let
        home = config.users.users.${user}.home;
      in ''
        marker=${lib.escapeShellArg "${home}/.local/state/herdr/nixos-bootstrap-units"}
        if [ -f "$marker" ]; then
          for unit in herdr-telegram-register.service herdr-server.service; do
            for suffix in "" /default.target.wants; do
              unit_path=${lib.escapeShellArg "${home}/.config/systemd/user"}"$suffix/$unit"
              if [ -L "$unit_path" ]; then
                case "$(${pkgs.coreutils}/bin/readlink "$unit_path")" in
                  /nix/store/*-unit-"$unit"/"$unit") ${pkgs.coreutils}/bin/rm "$unit_path" ;;
                esac
              fi
            done
          done
          ${pkgs.coreutils}/bin/rm "$marker"
        fi
      '') cfg.users;
    };
    systemd.user.services.herdr-telegram-register = {
      description = "Register the Nix-managed Herdr Telegram plugin";
      wantedBy = [ "default.target" ];
      unitConfig.ConditionUser = map (user: "|${user}") cfg.users;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = register;
      };
    };
    systemd.user.services.herdr-server = lib.mkIf cfg.server.enable {
      description = "Persistent Herdr server";
      wantedBy = [ "default.target" ];
      after = [ "herdr-telegram-register.service" ];
      requires = [ "herdr-telegram-register.service" ];
      path = [ cfg.herdrPackage cfg.package pkgs.nix pkgs.bashInteractive pkgs.coreutils pkgs.openssh pkgs.gitMinimal ];
      unitConfig.ConditionUser = map (user: "|${user}") cfg.users;
      serviceConfig = {
        ExecStart = server;
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
