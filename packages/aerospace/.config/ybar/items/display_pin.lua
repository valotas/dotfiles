local displays = require("helpers.displays")

local AEROSPACE = "/opt/homebrew/bin/aerospace"
if os.execute("test -x " .. AEROSPACE) ~= true then
  AEROSPACE = "/usr/local/bin/aerospace"
  if os.execute("test -x " .. AEROSPACE) ~= true then
    AEROSPACE = "aerospace"
  end
end

local MAX_SLOTS = 36
local FORMAT = "'%{workspace}|%{monitor-name}|%{monitor-appkit-nsscreen-screens-id}'"

local function pin_slot(slot, display)
  if not display then
    return
  end
  sbar.set("space." .. slot, { display = display })
  sbar.set("space.padding." .. slot, { display = display })
end

local function pin_workspaces()
  local info = displays.get()
  sbar.exec(
    AEROSPACE .. " list-workspaces --all --format " .. FORMAT .. " 2>/dev/null",
    function(out)
      local by_name = {}
      for line in (out or ""):gmatch("[^\r\n]+") do
        local name, monitor_name, screen_id = line:match("([^|]*)|([^|]*)|(.*)")
        if name and name ~= "" then
          local display
          if not info.has_external then
            display = info.builtin_value or screen_id
          elseif displays.on_builtin(monitor_name) then
            display = info.builtin_value
          else
            display = info.external_value or screen_id
          end
          by_name[name] = display
        end
      end

      for slot = 1, MAX_SLOTS do
        local queried = sbar.query("space." .. slot)
        local icon = queried and queried.icon
        local bound = icon and (icon.value or icon.string)
        if bound and bound ~= "" and by_name[bound] then
          pin_slot(slot, by_name[bound])
        end
      end
    end
  )
end

pin_workspaces()
sbar.delay(1, pin_workspaces)
sbar.delay(3, pin_workspaces)

local listener = sbar.add("item", "display.pin", {
  drawing = false,
  updates = true,
  update_freq = 5,
})
listener:subscribe({
  "aerospace_workspace_change",
  "aerospace_focus_changed",
  "aerospace_focused_monitor_changed",
  "front_app_switched",
  "display_change",
  "system_woke",
  "routine",
}, pin_workspaces)
