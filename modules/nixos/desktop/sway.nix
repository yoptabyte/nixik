{ config, lib, pkgs, inputs, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Disable xterm desktop manager and foot terminal
  services.xserver.desktopManager.xterm.enable = lib.mkForce false;
  programs.foot.enable = lib.mkForce false;

  # Explicitly remove xterm and foot from system packages
  services.xserver.excludePackages = [ pkgs.xterm pkgs.foot ];

  # Remove default packages added by Sway module (includes foot)
  programs.sway.extraPackages = lib.mkForce [];

  environment.systemPackages = with pkgs; [
    swaybg
    swayidle
    swaylock
    mako
    wl-clipboard
    grim
    slurp
    brightnessctl
    wmenu
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
    ];
    config.sway = {
      default = lib.mkDefault [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    };
  };

  # Vicinae launcher wrapper
  environment.etc."xdg/autostart/xcape-vicinae.desktop".text = ''
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
}
