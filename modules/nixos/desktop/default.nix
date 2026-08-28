{ ... }:
{
  imports = [ ./hyprland.nix ./xmonad.nix ./vicinae.nix ];
  services.displayManager.ly = {
    enable = true;
    settings = { load = false; save = false; };
  };
  services.displayManager.defaultSession = "hyprland-uwsm";
  services.xserver.xkb = { layout = "us,ru"; options = "grp:caps_toggle"; };
  services.xserver.desktopManager.xterm.enable = false;
  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:caps_toggle";
  };
}
