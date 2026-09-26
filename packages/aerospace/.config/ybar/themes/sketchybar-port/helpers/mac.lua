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

-- One pmset round-trip: callback(level, on_ac).
-- on_ac follows the menu bar: the bolt stays up whenever the Mac is drawing
-- from the adapter, including "charged" and "not charging".
function M.battery(callback)
  sbar.exec("pmset -g batt", function(out)
    out = out or ""
    local level = tonumber(out:match("(%d+)%%")) or 0
    local on_ac = out:find("AC Power") ~= nil
    callback(level, on_ac)
  end)
end

return M
