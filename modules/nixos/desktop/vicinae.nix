{ pkgs, lib, ... }:
{
  # Vicinae systemd user service
  systemd.user.services.vicinae = {
    description = "Vicinae server daemon";
    documentation = [ "https://docs.vicinae.com" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.vicinae} server --replace";
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
        "PATH=/home/yoptabyte/.local/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:${lib.makeBinPath [ pkgs.thunar pkgs.pavucontrol pkgs.pulseaudio ]}"
        "VICINAE_OVERRIDES=/home/yoptabyte/.config/vicinae/nix.json"
      ];
    };
  };

}
