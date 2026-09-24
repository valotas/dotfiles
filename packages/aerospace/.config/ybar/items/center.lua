local colors = require("colors")
local displays = require("helpers.displays")

local here = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"
local app_icons = dofile(here .. "../../sketchybar/helpers/app_icons.lua")
local APP_FONT = "sketchybar-app-font:Regular:16.0"

-- Apple logo is about 13pt wide. Keep it on the bar center, with the
-- title and clock clear of it by the same gap.
local GAP = 18
local APPLE = 13

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

-- Title flows left from the center; the Apple icon is the center item.
local external = sbar.add("item", "tokyonight.front_app.external", {
  position = "q",
  drawing = false,
  icon = app_icon,
  label = { color = colors.fg, padding_left = 2, padding_right = 4 },
  padding_right = GAP + APPLE / 2,
})

local apple = sbar.add("item", "tokyonight.apple", {
  position = "center",
  drawing = false,
  icon = {
    string = "sf:apple.logo",
    font = { size = 14 },
    color = colors.blue,
    padding_left = 0,
    padding_right = 0,
  },
  label = { drawing = false },
  padding_left = 0,
  padding_right = 0,
})

local front_name = ""

local function apply_front()
  local info = displays.get()
  local show = front_name ~= ""
  local glyph = show and app_icons.app_icon(front_name) or ""
  builtin:set({
    drawing = show,
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
  apple:set({
    drawing = info.has_external,
    display = info.external_value or "",
  })
end

builtin:subscribe("front_app_switched", function(env)
  front_name = env.INFO or ""
  apply_front()
end)
apple:subscribe({ "display_change", "system_woke" }, apply_front)
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
