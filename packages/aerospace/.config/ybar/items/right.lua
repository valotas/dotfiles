local colors = require("colors")
local mac = require("helpers.mac")

-- Right side, rightmost first after the clock: battery, volume, wifi.
-- Clock lives in items/calendar.lua so it can sit right vs center per display.

local BATTERY_ICON = "\u{F0079}"
local CHARGING_ICON = "\u{F0084}"

local battery = sbar.add("item", "tokyonight.battery", {
  position = "right",
  click_script = mac.BATTERY_SETTINGS,
  icon = { string = BATTERY_ICON, color = colors.blue },
  label = { color = colors.blue },
})
local function set_battery(level, charging)
  local color = charging and colors.green or (level > 20 and colors.blue or colors.red)
  battery:set({
    icon = { string = charging and CHARGING_ICON or BATTERY_ICON, color = color },
    label = { string = level .. "%", color = color },
  })
end
battery:subscribe({ "forced", "routine", "battery_change", "power_source_change" }, function()
  mac.battery(function(level, charging)
    set_battery(level, charging)
  end)
end)

sbar.add("item", "tokyonight.pad2", { position = "right", width = 10 })

local volume = sbar.add("item", "tokyonight.volume", {
  position = "right",
  icon = { string = "\u{F057E}", color = colors.purple },
  label = { color = colors.purple },
})
volume:subscribe("volume_change", function(env)
  local level = tonumber(env.INFO) or 0
  local glyph = level == 0 and "\u{F0581}"
    or (level < 40 and "\u{F057F}" or (level < 75 and "\u{F0580}" or "\u{F057E}"))
  volume:set({ icon = { string = glyph }, label = { string = level .. "%" } })
end)

volume:set({ click_script = mac.SOUND_SETTINGS })
mac.volume_scroll(volume)
sbar.trigger("volume_change")

sbar.add("item", "tokyonight.pad3", { position = "right", width = 10 })

local wifi = sbar.add("item", "tokyonight.wifi", {
  position = "right",
  icon = { string = "\u{F0928}", color = colors.blue },
  label = { drawing = false, color = colors.blue },
  click_script = "open 'x-apple.systempreferences:com.apple.wifi-settings-extension'",
})
wifi:subscribe("wifi_change", function(env)
  local info = env.INFO or ""
  local up = info ~= ""
  wifi:set({
    icon = {
      string = up and "\u{F0928}" or "\u{F092D}",
      color = up and colors.blue or colors.muted,
    },
    label = { drawing = up and info ~= "connected", string = info },
  })
end)

sbar.trigger("wifi_change")
