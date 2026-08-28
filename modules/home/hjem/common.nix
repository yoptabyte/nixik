{ inputs, pkgs, ... }:
{
  hjem = {
    clobberByDefault = true;
    extraModules = [ inputs.hjem-rum.result.hjemModules.default ];
    users.yoptabyte = {
      enable = true;
      files = {
        ".config/git/config".source = ../files/git/git-config;
        ".config/jj/config.toml".source = ../files/jj/jj-config.toml;
        ".config/ghostty/config".source = ../files/ghostty/ghostty-config;
        ".config/starship.toml".source = ../files/starship/starship.toml;
        ".config/helix/config.toml".source = ../files/helix/helix-config.toml;
        ".config/zed/settings.json".source = ../files/zed/zed-settings.json;
        ".config/yazi/yazi.toml".source = ../files/yazi/yazi.toml;
        ".config/yazi/keymap.toml".source = ../files/yazi/yazi-keymap.toml;
        ".local/bin/vicinae-launcher" = {
          executable = true;
          source = ../files/vicinae/vicinae-launcher;
        };
        ".local/bin/vesktop-bootstrap" = {
          executable = true;
          source = ../files/vesktop/vesktop-bootstrap;
        };
        ".local/share/applications/vesktop.desktop".source = ../files/vesktop/vesktop.desktop;
        ".config/autostart/com.mitchellh.ghostty.desktop".source = ../files/ghostty/ghostty-autostart.desktop;
        ".config/vicinae/nix.json".source = ../files/vicinae/vicinae-settings.json;
        ".config/vicinae/themes/amber-night.toml".source = ../files/vicinae/themes/vicinae-theme-amber-night.toml;
        ".config/vicinae/themes/amber-day.toml".source = ../files/vicinae/themes/vicinae-theme-amber-day.toml;
        ".config/vicinae/themes/ghostty-night.toml".source = ../files/vicinae/themes/vicinae-theme-ghostty-night.toml;
      };
      packages = (import ../../shared/home-packages.nix { inherit pkgs; }) ++ (with pkgs; [
        bluetui pulsemixer vicinae pulseaudio
      ]);
    };
  };
}
