{ pkgs, ... }:
let
  customSt = pkgs.st.overrideAttrs (_: {
    postPatch = ''cp ${../../home/files/st/st-config.h} config.h'';
  });
in
{
  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    haskellPackages = pkgs.haskellPackages;
  };
  environment.localBinInPath = true;
  environment.systemPackages = with pkgs; [
    xmobar dmenu customSt xclip scrot trayer feh xsecurelock picom snixembed
  ];
  hjem.users.yoptabyte.files = {
    ".xmonad/xmonad.hs".source = ../../home/files/xmonad/xmonad.hs;
    ".config/xmobar/xmobarrc".source = ../../home/files/xmobar/xmobarrc;
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
