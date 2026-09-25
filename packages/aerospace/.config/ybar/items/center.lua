local colors = require("colors")
local displays = require("helpers.displays")

local here = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"
local app_icons = dofile(here .. "../../sketchybar/helpers/app_icons.lua")
local APP_FONT = "sketchybar-app-font:Regular:16.0"

local app_icon = {
  font = APP_FONT,
  color = colors.fg,
  padding_left = 2,
  padding_right = 4,
  y_offset = 0,
}

local builtin = sbar.add("item", "tokyonight.front_app", {
  position = "q",
  icon = app_icon,
  label = { color = colors.fg, padding_left = 2, padding_right = 4 },
})

-- Title sits left of center on the external bar.
local external = sbar.add("item", "tokyonight.front_app.external", {
  position = "q",
  drawing = false,
  icon = app_icon,
  label = { color = colors.fg, padding_left = 2, padding_right = 4 },
})

local front_name = ""

local function apply_front()
  local info = displays.get()
  local show = front_name ~= ""
  local glyph = show and app_icons.app_icon(front_name) or ""
  -- An empty display value means every screen. Hide the built-in copy
  -- when that panel is not connected, or it stacks on the external bar.
  local show_builtin = show and (info.builtin_value ~= nil or not info.has_external)
  builtin:set({
    drawing = show_builtin,
    display = info.builtin_value or "",
    icon = { string = glyph },
    label = { string = front_name },
  })
  external:set({
    drawing = show and info.has_external,
    display = info.external_value or "",
    icon = { string = glyph },
    label = { string = front_name },
  })
end

builtin:subscribe("front_app_switched", function(env)
  front_name = env.INFO or ""
  apply_front()
end)
external:subscribe({ "display_change", "system_woke" }, apply_front)
sbar.trigger("front_app_switched")

local media = sbar.add("item", "tokyonight.media", {
  position = "e",
  drawing = false,
  updates = true,
  scroll_texts = true,
  icon = { string = "\u{F075A}", color = colors.green, padding_left = 8 },
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
