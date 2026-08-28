{ pkgs, ... }:
{
  hjem.users.yoptabyte.files = {
    ".config/tmux/tmux.conf".source = ../files/tmux/tmux-xps15.conf;
    ".config/nushell/config.nu".source = ../files/nushell/nushell-xps15.nu;
    ".local/share/applications/dev.zed.Zed.desktop".source = ../files/zed/zed-nvidia.desktop;
    ".config/JetBrains/IntelliJIdea2026.2/colors/K380 Graphite.icls".source = ../files/intellij/k380-graphite.icls;
    ".config/JetBrains/IntelliJIdea2026.2/colors/Kanagawa Lotus.icls".source = ../files/intellij/kanagawa-lotus.icls;
    ".background-image".source = ../../../wallpapers/nix-wallpaper-k380.png;
  };
  hjem.users.yoptabyte.packages = with pkgs; [ cliphist ffmpeg arandr ];
}
