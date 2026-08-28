-- Hyprland 0.56 Lua configuration adapted from Opinionated-Nix / Omarchy.
-- The local launchers and XMonad key habits take precedence over its menu binds.

hl.env("XCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
  input = {
    kb_layout = "us,ru",
    kb_options = "grp:caps_toggle,shift:both_capslock",
    follow_mouse = 1,
    touchpad = { natural_scroll = false },
  },
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = "#98971a",
      inactive_border = "#bdae93",
    },
    layout = "dwindle",
  },
  decoration = {
    rounding = 8,
    shadow = {
      enabled = true,
      range = 12,
      render_power = 3,
      color = "rgba(3c383640)",
    },
    blur = {
      enabled = true,
      size = 4,
      passes = 2,
      vibrancy = 0.06,
      vibrancy_darkness = 0.02,
    },
  },
  animations = { enabled = true },
  dwindle = { preserve_split = true },
  group = { groupbar = { stacked = false } },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})

-- Give window, layer and workspace changes their own motion.  The curves are
-- deliberately quick enough for tiling workflows while remaining visible.
hl.curve("gentle", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("swift", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("fade", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })

hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "gentle" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.8, bezier = "gentle" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5.2, bezier = "gentle", style = "popin 88%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.8, bezier = "swift", style = "popin 88%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.2, bezier = "fade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.4, bezier = "fade" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "gentle" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2.5, bezier = "fade" })
hl.animation({ leaf = "layers", enabled = true, speed = 4.5, bezier = "gentle" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4.5, bezier = "gentle", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.5, bezier = "swift", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3, bezier = "fade" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.2, bezier = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "gentle", style = "slide" })

-- Hyprland reloads this file after loading the plugin from the Nix store.
for _, plugin in ipairs(hl.get_loaded_plugins()) do
  if plugin.name == "hyprexpo" then
    hl.config({
      plugin = {
        hyprexpo = {
          columns = 5,
          rows = 2,
          dynamic_grid = 0,
          skip_empty = 0,
          workspace_method = "first 1",
          bg_col = "rgb(fbf1c7)",
        },
      },
    })
    hl.bind("SUPER + G", function()
      if hl.plugin.hyprexpo then
        hl.plugin.hyprexpo.expo("toggle")
      end
    end, { description = "Workspace overview" })
    break
  end
end

-- Transparent applications pick up the compositor blur.  Focused windows
-- remain legible while inactive ones recede slightly into the wallpaper.
for _, app_class in ipairs({
  "^com[.]mitchellh[.]ghostty$",
  "^Thunar$",
  "^md[.]obsidian[.]Obsidian$",
  "^(dev[.]zed[.]Zed|zeditor|Zed)$",
  "^[Ee]macs$",
  "^vicinae$",
  "^(com[.]ayugram[.]desktop|AyuGram)$",
}) do
  hl.window_rule({ match = { class = app_class }, opacity = "0.85 override 0.77 override 0.85 override" })
end

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("/home/yoptabyte/.local/bin/awww-wallpaper")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("waybar")
  hl.exec_cmd("mako")
  hl.exec_cmd("hyprpolkitagent")
  hl.exec_cmd("systemctl --user start voxtype.service")
end)

local function run(keys, command, description, options)
  local opts = options or {}
  opts.description = description
  hl.bind(keys, hl.dsp.exec_cmd(command), opts)
end

local function phantomat_loaded()
  for _, plugin in ipairs(hl.get_loaded_plugins()) do
    if plugin.name == "spatialoverview" then return true end
  end
  return false
end

local function native_only(dispatcher)
  return function()
    if not phantomat_loaded() then hl.dispatch(dispatcher) end
  end
end

-- Identical launcher bindings in Hyprland and XMonad.
run("SUPER + D", "vicinae open", "Vicinae")
run("SUPER + P", (os.getenv("HOME") or "/home/yoptabyte") .. "/.local/bin/dmenu_run -b", "dmenu")
run("SUPER + SHIFT + D", (os.getenv("HOME") or "/home/yoptabyte") .. "/.local/bin/dmenu_run", "dmenu")
run("SUPER + RETURN", "ghostty", "Terminal")
run("SUPER + CTRL + G", "/home/yoptabyte/.local/bin/phantomat-workspace", "Canvas on current workspace")
run("SUPER + CTRL + SHIFT + G", "/home/yoptabyte/.local/bin/phantomat-workspace navigate", "Canvas overview")

hl.on("workspace.active", function()
  hl.exec_cmd("/home/yoptabyte/.local/bin/phantomat-workspace leave")
end)

hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close window" })
run("SUPER + SHIFT + E", "uwsm stop", "Exit Hyprland")
run("SUPER + SHIFT + C", "hyprctl reload", "Reload Hyprland")

local directions = { H = "l", J = "d", K = "u", L = "r" }
for key, direction in pairs(directions) do
  hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = direction }), { description = "Focus " .. direction })
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.swap({ direction = direction }), { description = "Swap " .. direction })
end

for _, pair in ipairs({ { "LEFT", "l" }, { "DOWN", "d" }, { "UP", "u" }, { "RIGHT", "r" } }) do
  hl.bind("SUPER + " .. pair[1], hl.dsp.focus({ direction = pair[2] }))
  hl.bind("SUPER + SHIFT + " .. pair[1], hl.dsp.window.swap({ direction = pair[2] }))
end

-- Grouped windows share one tile, with horizontal tabs like i3's tabbed mode.
hl.bind("SUPER + S", native_only(hl.dsp.group.toggle()), { description = "Toggle window group" })
hl.bind("SUPER + SHIFT + S", native_only(hl.dsp.window.move({ out_of_group = true })), { description = "Remove window from group" })
hl.bind("SUPER + TAB", function()
  if phantomat_loaded() then
    hl.plugin.spatialoverview.canvas("switch next")
  else
    hl.dispatch(hl.dsp.group.next())
  end
end, { description = "Next window or group tab" })
hl.bind("SUPER + SHIFT + TAB", function()
  if phantomat_loaded() then
    hl.plugin.spatialoverview.canvas("switch prev")
  else
    hl.dispatch(hl.dsp.group.prev())
  end
end, { description = "Previous window or group tab" })
for key, direction in pairs(directions) do
  hl.bind("SUPER + CTRL + " .. key, native_only(hl.dsp.window.move({ into_or_create_group = direction })), { description = "Group window " .. direction })
end

hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Full screen" })
hl.bind("SUPER + T", function()
  if phantomat_loaded() then
    hl.plugin.spatialoverview.canvas("fill")
  else
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  end
end, { description = "Fill canvas window or toggle floating" })
hl.bind("SUPER + SHIFT + SPACE", native_only(hl.dsp.window.float({ action = "toggle" })))
hl.bind("SUPER + V", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
hl.bind("SUPER + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
hl.bind("SUPER + minus", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = tostring(workspace) }), { description = "Workspace " .. workspace })
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(workspace) }), { description = "Move to workspace " .. workspace })
end

run("PRINT", "grim -g \"$(slurp)\" - | wl-copy", "Screenshot to clipboard")
run("SUPER + PRINT", "grim -g \"$(slurp)\" \"$HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png\"", "Save screenshot")
run("SUPER + SHIFT + X", "loginctl lock-session", "Lock screen")
run("SUPER + CTRL + X", "voxtype record toggle", "Toggle dictation")
run("F9", "voxtype record start", "Dictation push-to-talk")
run("F9", "voxtype record stop", "Stop dictation", { release = true })

run("XF86AudioRaiseVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+", "Volume up", { locked = true, repeating = true })
run("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", "Volume down", { locked = true, repeating = true })
run("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", "Mute", { locked = true })
run("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", "Mute microphone", { locked = true })
run("XF86MonBrightnessUp", "brightnessctl set +5%", "Brightness up", { locked = true, repeating = true })
run("XF86MonBrightnessDown", "brightnessctl set 5%-", "Brightness down", { locked = true, repeating = true })
