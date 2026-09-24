local colors = require("colors")
local logging = require("helpers.logging")
local displays = require("helpers.displays")

local PREFER_EXTERNAL_MAIN = os.getenv("HOME") .. "/.config/sketchybar/helpers/bin/prefer_external_main"

local function display_value(ids)
  if #ids == 0 then
    return ""
  end
  if #ids == 1 then
    return tonumber(ids[1]) or ids[1]
  end
  return table.concat(ids, ",")
end

local function create_bar_config(bar_name)
  local main_bar = displays.is_main_bar(bar_name)
  local info = displays.get()
  local ids = main_bar and info.builtin or info.externals
  local display = display_value(ids)
  local hidden = #ids == 0
  local height = main_bar and 40 or 30
  if hidden then
    height = 0
  end

  logging.log("Creating bar config for " .. bar_name .. " on display " .. tostring(display) .. " with height " .. height .. " has_external " .. tostring(info.has_external))
  return {
    height = height,
    color = colors.bar.bg,
    padding_right = main_bar and 5 or 15,
    padding_left = main_bar and 5 or 15,
    display = display,
  }
end


local bar = nil

local function update_bar_config()
  local bar_name = os.getenv("BAR_NAME") or "sketchybar"
  logging.log("update bar: " .. bar_name)
  local config = create_bar_config(bar_name)
  if bar then
    bar:set(config)
  else
    bar = sbar.bar(config)
  end
end

local function refresh()
  update_bar_config()
  sbar.exec("sleep 0.5", function()
    logging.log("display_change retry")
    update_bar_config()
  end)
end

update_bar_config()

if displays.is_main_bar() then
  sbar.exec(PREFER_EXTERNAL_MAIN, function()
    update_bar_config()
  end)
end

-- Use sketchybar's built-in display_change; do not rebind it to a Darwin notification.
local listener = sbar.add("item", "display", { drawing = false })
listener:subscribe({ "display_change", "system_woke" }, function(env)
  logging.log("display_change: " .. tostring(env.SENDER))
  if displays.is_main_bar() then
    sbar.exec(PREFER_EXTERNAL_MAIN, function()
      refresh()
    end)
  else
    refresh()
  end
end)
