local colors = require("colors")
local mac = require("helpers.mac")

-- Right side, rightmost first after the clock: battery, volume, wifi.
-- Clock lives in items/calendar.lua so it can sit right vs center per display.
-- CodexBar usage sits just left of this group (items/usage.lua).

local function battery_symbol(level, on_ac)
  -- The menu bar keeps the bolt in the battery for the whole time the Mac
  -- is on adapter power. Only the full battery has a bolt variant.
  if on_ac then
    return "sf:battery.100.bolt"
  end
  if level > 87 then
    return "sf:battery.100"
  elseif level > 62 then
    return "sf:battery.75"
  elseif level > 37 then
    return "sf:battery.50"
  elseif level > 12 then
    return "sf:battery.25"
  end
  return "sf:battery.0"
end

local battery = sbar.add("item", "tokyonight.battery", {
  position = "right",
  click_script = mac.BATTERY_SETTINGS,
  icon = { string = "sf:battery.100", color = colors.blue },
  label = { color = colors.blue },
})
local function set_battery(level, on_ac)
  local color = on_ac and colors.green or (level > 20 and colors.blue or colors.red)
  battery:set({
    icon = { string = battery_symbol(level, on_ac), color = color },
    label = { string = level .. "%", color = color },
  })
end
battery:subscribe({ "forced", "routine", "battery_change", "power_source_change" }, function()
  mac.battery(set_battery)
end)
mac.battery(set_battery)

sbar.add("item", "tokyonight.pad2", { position = "right", width = 4 })

local volume = sbar.add("item", "tokyonight.volume", {
  position = "right",
  icon = { string = "sf:speaker.wave.2.fill", color = colors.purple },
  label = { color = colors.purple },
})
volume:subscribe("volume_change", function(env)
  local level = tonumber(env.INFO) or 0
  local glyph = level == 0 and "sf:speaker.slash.fill"
    or (level < 40 and "sf:speaker.wave.1.fill" or (level < 75 and "sf:speaker.wave.2.fill" or "sf:speaker.wave.3.fill"))
  volume:set({ icon = { string = glyph }, label = { string = level .. "%" } })
end)

volume:set({ click_script = mac.SOUND_SETTINGS })
mac.volume_scroll(volume)
sbar.trigger("volume_change")

sbar.add("item", "tokyonight.pad3", { position = "right", width = 4 })

local wifi = sbar.add("item", "tokyonight.wifi", {
  position = "right",
  icon = { string = "sf:wifi", color = colors.blue },
  label = { drawing = false, color = colors.blue },
  click_script = "open 'x-apple.systempreferences:com.apple.wifi-settings-extension'",
})
wifi:subscribe("wifi_change", function(env)
  local info = env.INFO or ""
  local up = info ~= ""
  wifi:set({
    icon = {
      string = up and "sf:wifi" or "sf:wifi.slash",
      color = up and colors.blue or colors.muted,
    },
    label = { drawing = up and info ~= "connected", string = info },
  })
end)

sbar.trigger("wifi_change")
