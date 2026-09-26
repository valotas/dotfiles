local colors = require("colors")
local displays = require("helpers.displays")
local mac = require("helpers.mac")

local function clock_item(name, position)
  return sbar.add("item", name, {
    position = position,
    click_script = mac.CALENDAR,
    update_freq = 20,
    icon = { string = "sf:clock", color = colors.blue },
    label = { color = colors.blue },
  })
end

local builtin_cal = clock_item("calendar.builtin", "right")
local external_cal = clock_item("calendar.external", "center")

local function clock_string()
  return os.date("%a %d/%m %H:%M")
end

local function tick()
  local label = { string = clock_string() }
  builtin_cal:set({ label = label })
  external_cal:set({ label = label })
end

local function apply_displays()
  local info = displays.get()
  -- An empty display value means every screen. Hide the built-in clock
  -- when that panel is not connected, or it stacks on the external bar.
  local show_builtin = info.builtin_value ~= nil or not info.has_external
  if show_builtin then
    builtin_cal:set({
      drawing = true,
      display = info.builtin_value or "",
      position = "e",
      padding_left = 10,
    })
  else
    builtin_cal:set({ drawing = false })
  end
  if info.has_external then
    external_cal:set({
      drawing = true,
      display = info.external_value,
      position = "e",
      padding_left = 10,
    })
  else
    external_cal:set({ drawing = false })
  end
end

tick()
apply_displays()

builtin_cal:subscribe({ "forced", "routine", "system_woke" }, tick)
external_cal:subscribe({ "forced", "routine", "system_woke" }, tick)

local listener = sbar.add("item", "calendar.display_listener", { drawing = false })
listener:subscribe({ "display_change", "system_woke" }, apply_displays)
