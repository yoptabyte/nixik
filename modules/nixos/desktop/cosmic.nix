# { config, lib, pkgs, inputs, ... }:
# {
#   # COSMIC Desktop Environment
#   services.desktopManager.cosmic.enable = true;
#   environment.cosmic.excludePackages = with pkgs; [
#     cosmic-term
#   ];
#
#   # COSMIC Greeter (Display Manager)
#   services.displayManager.cosmic-greeter.enable = true;
#
#   # System76 Scheduler
#   services.system76-scheduler.enable = true;
#
#   # Keyboard layout for Wayland/COSMIC - US + RU with Caps Lock switching
#   environment.sessionVariables = {
#     XKB_DEFAULT_LAYOUT = "us,ru";
#     XKB_DEFAULT_OPTIONS = "grp:caps_toggle";
#   };
#
#   # XDG portals for Wayland
#   xdg.portal = {
#     enable = true;
#     extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
#   };
# }
