local colors = require("colors")
local displays = require("helpers.displays")
local mac = require("helpers.mac")

local function clock_item(name, position)
  return sbar.add("item", name, {
    position = position,
    click_script = mac.CALENDAR,
    update_freq = 20,
    icon = { string = "\u{F0954}", color = colors.blue },
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
  if info.has_external then
    builtin_cal:set({
      drawing = true,
      display = info.builtin_value,
      position = "e",
      padding_left = 10,
    })
    external_cal:set({
      drawing = true,
      display = info.external_value,
      -- Right of the centered Apple icon, matching the title's gap.
      position = "e",
      padding_left = 18 + 7,
    })
  else
    builtin_cal:set({
      drawing = true,
      display = info.builtin_value or "",
      position = "e",
      padding_left = 10,
    })
    external_cal:set({ drawing = false })
  end
end

tick()
apply_displays()

builtin_cal:subscribe({ "forced", "routine", "system_woke" }, tick)
external_cal:subscribe({ "forced", "routine", "system_woke" }, tick)

local listener = sbar.add("item", "calendar.display_listener", { drawing = false })
listener:subscribe({ "display_change", "system_woke" }, apply_displays)
