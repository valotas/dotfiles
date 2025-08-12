local colors = require("colors")
local logging = require("helpers.logging")

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
    alternative = alternate_display,
  }
end

local function create_bar_config(bar_name)
  local main_bar = bar_name == "sketchybar_main"
  local displays = get_displays()
  local alternative_displays = #displays.alternative > 0 and table.concat(displays.alternative, ",") or ""
  logging.log("dispays.main: " .. displays.main .. " displays.alternative: " .. alternative_displays)
  local display = main_bar and displays.main > 0 and displays.main or alternative_displays
  local hidden = bar_name == "sketchybar_main" and displays.main == 0 or bar_name == "sketchybar_alternative" and #displays.alternative == 0
  local height = main_bar and 40 or 30
  if (hidden) then
    height = 0
  end

  logging.log("Creating bar config for " .. bar_name .. " on display " .. display .. " with height " .. height .. " and hidden " .. tostring(hidden))
  return {
    height = height,
    color = colors.bar.bg,
    padding_right = bar_name == "sketchybar_main" and 5 or 15,
    padding_left = bar_name == "sketchybar_main" and 5 or 15,
    display = display,
  }
end


local bar = nil

local function update_bar_config()
  local bar_name = os.getenv("BAR_NAME")
  logging.log("update bar: " .. bar_name)
  local config = create_bar_config(bar_name)
  if bar then
    bar:set(config)
  else
    bar = sbar.bar(config)
  end
end

update_bar_config()

sbar.add("event", "display_change", "NSSecondaryDisplayVisChanged")

local listener = sbar.add("item", "display")
listener:subscribe("display_change", function()
  logging.log("display_change")
  update_bar_config()
end)