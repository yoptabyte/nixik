-- XPS 15: use the LG ultrawide when connected, otherwise use the laptop panel.
local internal = {
  output = "eDP-1",
  mode = "1920x1200@59.95",
  position = "0x0",
  scale = 1.5,
}

hl.monitor(internal)
hl.monitor({
  output = "DP-2",
  mode = "2560x1080@100",
  position = "0x0",
  scale = 1,
})

local function update_internal_monitor()
  local external_connected = hl.get_monitor("DP-2") ~= nil
  local internal_enabled = hl.get_monitor("eDP-1") ~= nil

  if external_connected and internal_enabled then
    hl.monitor({ output = "eDP-1", disabled = true })
  elseif not external_connected and not internal_enabled then
    hl.monitor(internal)
  end
end

hl.on("hyprland.start", update_internal_monitor)
hl.on("config.reloaded", update_internal_monitor)
hl.on("monitor.added", function(monitor)
  if monitor.name == "DP-2" then
    update_internal_monitor()
  end
end)
hl.on("monitor.removed", function(monitor)
  if monitor.name == "DP-2" then
    hl.monitor(internal)
  end
end)

update_internal_monitor()
