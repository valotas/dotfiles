local colors = require("colors")
local logging = require("helpers.logging")

local bar = {}

local function get_displays()
  local displays = sbar.query("displays")

  local main_display = 0
  local alternate_display = {}

  for _, display in ipairs(displays) do
    local displayId = display["arrangement-id"]
    if display.UUID == "37D8832A-2D66-02CA-B9F7-8F30A301B230" then
      main_display = displayId
    else 
      table.insert(alternate_display, displayId)
    end
  end
  return {
    -- the build in display
    main = main_display,

    -- the external displays
    alternate = alternate_display,
  }
end

bar.create_bar_config = function(bar_name)
  local main_bar = bar_name == "sketchybar_main"
  local displays = get_displays()
  local display = main_bar and displays.main > 0 and displays.main or table.concat(displays.alternate, ",")
  local height = main_bar and 40 or 30

  logging.log("Creating bar config for " .. bar_name .. " on display " .. display .. " with height " .. height)
  return {
    height = height,
    hidden = bar_name == "sketchybar_main" and displays.main == 0 or bar_name == "sketchybar_alternate" and #displays.alternate == 0,
    color = colors.bar.bg,
    padding_right = bar_name == "sketchybar_main" and 5 or 15,
    padding_left = bar_name == "sketchybar_main" and 5 or 15,
    display = display,
  }
end

return bar