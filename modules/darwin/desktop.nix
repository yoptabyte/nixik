{ pkgs, lib, ... }:
{
  # AeroSpace launchd service (tiling WM for macOS)
  launchd.user.agents.aerospace = {
    command = "/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
  };

  # SketchyBar launchd service — manual plist (nix-darwin's exec wrapper breaks two-step startup)

  # Symlink AeroSpace.app to /Applications for stable Accessibility permission path
  system.activationScripts.aerospace-symlink = {
    text = ''
      ln -sf ${pkgs.aerospace}/Applications/AeroSpace.app /Applications/AeroSpace.app
    '';
  };

  # Disable Ghostty auto-launch
  system.activationScripts.ghostty-no-autostart = {
    text = ''
      sudo -u yoptabyte /bin/sh -c '
        defaults write com.mitchellh.ghostty ApplePersistence -bool false 2>/dev/null
        defaults write com.mitchellh.ghostty NSQuitAlwaysKeepsWindows -bool false 2>/dev/null
      '
    '';
  };

  # Reload sketchybar launchd after activation (writes real plist so it survives reboot)
  system.activationScripts.sketchybar-launchd = let
    sketchybarPlist = pkgs.writeText "org.nixos.sketchybar.plist" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>KeepAlive</key>
          <true/>
          <key>Label</key>
          <string>org.nixos.sketchybar</string>
          <key>ProgramArguments</key>
          <array>
              <string>/bin/sh</string>
              <string>-c</string>
              <string>/bin/wait4path /nix/store &amp;&amp; ${lib.getExe pkgs.sketchybar} &amp; sleep 2 &amp;&amp; /bin/bash $HOME/.config/sketchybar/sketchybarrc &amp;&amp; wait</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
      </dict>
      </plist>
    '';
  in {
    text = ''
      sudo -u yoptabyte /bin/sh -c '
        launchctl bootout gui/$(id -u)/org.nixos.sketchybar 2>/dev/null
        sleep 1
        cp ${sketchybarPlist} $HOME/Library/LaunchAgents/org.nixos.sketchybar.plist
        launchctl enable gui/$(id -u)/org.nixos.sketchybar
        launchctl bootstrap gui/$(id -u) $HOME/Library/LaunchAgents/org.nixos.sketchybar.plist
        echo "sketchybar: launchd reloaded"
      '
    '';
  };

}
