-- macOS integration helpers shared by the shipped themes (themes already
-- reach this tree for the compat shim). Everything here is optional sugar:
-- Settings deep links, scroll-to-adjust volume, charging-aware battery query.
local M = {}

M.SOUND_SETTINGS = "open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'"
M.BATTERY_SETTINGS = "open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'"
M.WIFI_SETTINGS = "open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"
M.CALENDAR = "open -a Calendar"

-- Scroll on the item adjusts the output volume (4% per tick); the
-- volume_change event repaints the module. `ybar.volume` writes CoreAudio
-- in-process, and the signed string form steps from the current level, so
-- a scroll burst no longer spawns an osascript per tick.
function M.volume_scroll(item)
  item:subscribe("mouse.scrolled", function(env)
    local delta = tonumber(env.SCROLL_DELTA) or 0
    if delta == 0 then return end
    local err = ybar.volume(delta > 0 and "+4" or "-4")
    if err then print(err) end
  end)
end

-- One pmset round-trip: callback(level, charging).
-- charging is true only while the pack is taking a charge. Plugged-in
-- states ("charged", "not charging") and "discharging" stay false — a
-- bare "charging" search would also match those.
function M.battery(callback)
  sbar.exec("pmset -g batt", function(out)
    out = out or ""
    local level = tonumber(out:match("(%d+)%%")) or 0
    local status = (out:match("%%;%s*([^;]+)") or ""):lower()
    local charging = status:find("^charging") ~= nil or status:find("finishing charge") ~= nil
    callback(level, charging)
  end)
end

return M
