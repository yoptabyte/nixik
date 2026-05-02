# { config, lib, pkgs, inputs, ... }:
# let
#   xfceX11Session = (pkgs.runCommandLocal "xfce-x11-session" { } ''
#     mkdir -p "$out/share/xsessions"
#     ln -s ${pkgs.xfce4-session}/share/xsessions/xfce.desktop "$out/share/xsessions/xfce.desktop"
#   '').overrideAttrs
#     (_: {
#       passthru.providedSessions = [ "xfce" ];
#     });
# in
# {
#   services.xserver.desktopManager.xfce.enable = true;
#
#   # Make X11/Wayland session desktop entries visible to the greeter.
#   environment.pathsToLink = [
#     "/share/xsessions"
#   ];
#
#   services.displayManager.sessionPackages = [
#     xfceX11Session
#   ];
#
#   # COSMIC greeter launches X11 sessions through startx.
#   environment.systemPackages = with pkgs; [
#     xinit
#   ];
#
#   environment.xfce.excludePackages = with pkgs; [
#     parole
#     ristretto
#     thunar-volman
#     #xfce.xfce4-appfinder
#     xfce4-taskmanager
#     xfce4-terminal
#     xfce4-screensaver
#   ];
# }
