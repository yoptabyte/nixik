{ pkgs, ... }:
{
  hjem.users.yoptabyte.files = {
    ".config/tmux/tmux.conf".source = ../files/tmux/tmux-thinkpad-x390.conf;
    ".config/nushell/config.nu".source = ../files/nushell/nushell-thinkpad-x390.nu;
  };
}
