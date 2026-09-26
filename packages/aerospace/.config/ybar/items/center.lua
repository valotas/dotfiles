local colors = require("colors")
local displays = require("helpers.displays")
local tinted = require("helpers.tinted_icon")

local aerospace = "/opt/homebrew/bin/aerospace"
if os.execute("test -x " .. aerospace) ~= true then
  aerospace = "/usr/local/bin/aerospace"
  if os.execute("test -x " .. aerospace) ~= true then
    aerospace = "aerospace"
  end
end

local app_image = {
  string = "",
  drawing = false,
  size = 22,
  padding_left = 2,
  padding_right = 4,
}

local builtin = sbar.add("item", "tokyonight.front_app", {
  position = "q",
  icon = { drawing = false },
  image = app_image,
  label = { color = colors.fg, padding_left = 2, padding_right = 4 },
})

-- Title sits left of center on the external bar.
local external = sbar.add("item", "tokyonight.front_app.external", {
  position = "q",
  drawing = false,
  icon = { drawing = false },
  image = app_image,
  label = { color = colors.fg, padding_left = 2, padding_right = 4 },
})

local front_name = ""
local front_icon = nil
local display_info = displays.get()

local function focused_window()
  local handle = io.popen(
    aerospace .. " list-windows --focused --format '%{app-name}|%{app-bundle-path}' 2>/dev/null"
  )
  if not handle then
    return "", ""
  end
  local line = (handle:read("*a") or ""):gsub("%s+$", "")
  handle:close()
  local name, bundle = line:match("^(.-)|(.+)$")
  return name or "", bundle or ""
end

local function apply_front()
  local info = display_info
  local show = front_name ~= ""
  local app_icon = {
    string = front_icon or (show and ("app." .. front_name) or ""),
    drawing = show,
    desaturate = front_icon == nil,
    size = 22,
  }
  -- An empty display value means every screen. Hide the built-in copy
  -- when that panel is not connected, or it stacks on the external bar.
  local show_builtin = show and (info.builtin_value ~= nil or not info.has_external)
  builtin:set({
    drawing = show_builtin,
    display = info.builtin_value or "",
    image = app_icon,
    label = { string = front_name },
  })
  external:set({
    drawing = show and info.has_external,
    display = info.external_value or "",
    image = app_icon,
    label = { string = front_name },
  })
end

local function refresh_focused()
  local name, bundle = focused_window()
  front_name = name
  front_icon = name ~= "" and tinted.path(bundle, colors.fg) or nil
  apply_front()
end

local function refresh_displays()
  display_info = displays.get()
  apply_front()
end

-- The visible copies use updates=when_shown, so a hidden one never hears
-- the event. This listener stays armed on every display.
local listener = sbar.add("item", "tokyonight.front_app.listener", {
  drawing = false,
  updates = true,
})
-- AeroSpace fires this as the focused window changes, before macOS
-- promotes that app to frontmost.
listener:subscribe("aerospace_focus_changed", refresh_focused)
listener:subscribe({ "display_change", "system_woke" }, refresh_displays)
refresh_focused()

local media = sbar.add("item", "tokyonight.media", {
  position = "e",
  drawing = false,
  updates = true,
  scroll_texts = true,
  icon = { string = "sf:music.note", color = colors.green, padding_left = 8 },
  label = { width = 130, color = colors.fg },
})
local media_app = nil
media:subscribe("media_change", function(env)
  local state = env.MEDIA_STATE or ""
  local show = state == "playing" or state == "paused"
  media_app = env.MEDIA_APP
  local artist = env.MEDIA_ARTIST or ""
  local title = env.MEDIA_TITLE or ""
  media:set({
    drawing = show,
    label = {
      string = (artist ~= "" and (artist .. " - ") or "") .. title,
      color = state == "playing" and colors.fg or colors.muted,
    },
  })
end)
media:subscribe("mouse.clicked", function()
  if media_app then
    sbar.exec("osascript -e 'tell application \"" .. media_app .. "\" to playpause'")
  end
end)
