{ waybar }:
waybar.overrideAttrs (old: {
  # Backport upstream hotplug handling: disappearing power_supply devices
  # must not throw an exception out of the battery worker thread.
  patches = (old.patches or []) ++ [ ./waybar-battery-hotplug.patch ];
})
