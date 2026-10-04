{ config, pkgs, lib, ... }:
let
  customSt = pkgs.st.overrideAttrs (_: {
    postPatch = ''cp ${../../home/files/st/st-config.h} config.h'';
  });
  session = pkgs.writeShellApplication {
    name = "xmonad-session";
    runtimeInputs = with pkgs; [ python3 xrandr xmobar trayer picom snixembed procps ];
    text = ''
      exec python3 ${../../home/files/xmonad/session.py} ${lib.optionalString (config.networking.hostName == "xps15") "--prefer-dp-1"}
    '';
  };
  status = pkgs.writeShellApplication {
    name = "xmobar-status";
    runtimeInputs = with pkgs; [ python3 pulseaudio ];
    text = ''exec python3 ${../../home/files/xmobar/status.py}'';
  };
  login = pkgs.writeShellScript "xmonad-login" ''
    set -e
    # Hjem changes the symlink, but the store file's timestamp can be older
    # than the cached binary. XMonad's automatic mtime check then skips it.
    xmonad --recompile
    exec xmonad
  '';
in
{
  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    haskellPackages = pkgs.haskellPackages;
  };
  # XMonad is this desktop's only X11 window manager.
  services.xserver.windowManager.session = lib.mkForce [ {
    name = "xmonad";
    start = ''
      systemd-cat -t xmonad -- ${login} &
      waitPID=$!
    '';
  } ];
  environment.localBinInPath = true;
  environment.systemPackages = with pkgs; [
    xmobar dmenu customSt xclip scrot trayer feh xsecurelock picom snixembed
  ];
  hjem.users.yoptabyte.files = {
    ".xmonad/xmonad.hs".source = ../../home/files/xmonad/xmonad.hs;
    ".config/xmobar/xmobarrc".source = ../../home/files/xmobar/xmobarrc;
    ".config/picom/picom.conf".source = ../../home/files/picom/picom.conf;
    ".local/bin/xmonad-session".source = "${session}/bin/xmonad-session";
    ".local/bin/xmobar-status".source = "${status}/bin/xmobar-status";
    ".Xresources".source = ../../home/files/x11/Xresources;
    ".local/bin/dmenu" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        exec ${pkgs.dmenu}/bin/dmenu -nb '#fbf1c7' -nf '#3c3836' -sb '#98971a' -sf '#3c3836' "$@"
      '';
    };
    # Use sh instead of $SHELL because the user's shell is Nushell.
    ".local/bin/dmenu_run" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        ${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu -nb '#fbf1c7' -nf '#3c3836' -sb '#98971a' -sf '#3c3836' "$@" | ${pkgs.runtimeShell} &
      '';
    };
  };
}
