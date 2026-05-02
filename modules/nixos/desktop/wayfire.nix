# { config, lib, pkgs, inputs, ... }:
# {
#   programs.wayfire = {
#     enable = true;
#     plugins = with pkgs.wayfirePlugins; [
#       wcm
#       wf-shell
#       wayfire-plugins-extra
#     ];
#   };
#
#   environment.systemPackages = with pkgs; [
#     swaybg
#     swayidle
#     swaylock
#     mako
#     wl-clipboard
#     grim
#     slurp
#   ];
#
#   environment.sessionVariables = {
#     NIXOS_OZONE_WL = "1";
#     MOZ_ENABLE_WAYLAND = "1";
#     XKB_DEFAULT_LAYOUT = "us,ru";
#     XKB_DEFAULT_OPTIONS = "grp:caps_toggle";
#   };
#
#   xdg.portal = {
#     enable = true;
#     extraPortals = [
#       pkgs.xdg-desktop-portal-wlr
#       pkgs.xdg-desktop-portal-cosmic
#     ];
#     config = {
#       wayfire = {
#         default = [ "wlr" ];
#         "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
#         "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
#       };
#     };
#   };
# }
