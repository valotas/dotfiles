local displays = {}

-- Built-in MacBook panel. Any other UUID is treated as an external.
local BUILTIN_UUID = "37D8832A-2D66-02CA-B9F7-8F30A301B230"

local function as_id(value)
  if value == nil then
    return nil
  end
  return tostring(value)
end

local function consider(display, builtin, externals)
  if type(display) ~= "table" then
    return
  end
  local display_id = as_id(display["arrangement-id"])
  if not display_id then
    return
  end
  if display.UUID == BUILTIN_UUID then
    table.insert(builtin, display_id)
  else
    table.insert(externals, display_id)
  end
end

function displays.is_main_bar(bar_name)
  bar_name = bar_name or os.getenv("BAR_NAME") or "sketchybar"
  return bar_name == "sketchybar_main" or bar_name == "sketchybar"
end

-- Built-in MacBook panel vs everything else. Bars are pinned to hardware, not macOS "main".
function displays.get()
  local queried = sbar.query("displays") or {}
  local builtin = {}
  local externals = {}

  if queried[1] then
    for _, display in ipairs(queried) do
      consider(display, builtin, externals)
    end
  else
    for _, display in pairs(queried) do
      consider(display, builtin, externals)
    end
  end

  return {
    builtin = builtin,
    externals = externals,
    has_external = #externals > 0,
  }
end

function displays.on_builtin(workspace)
  local name = string.lower(tostring(workspace.monitor_name or ""))
  return name:find("built%-in", 1) ~= nil
end

-- Main bar is always the laptop; alternative is always the external.
function displays.workspace_on_bar(workspace, bar_name, info)
  local main_bar = displays.is_main_bar(bar_name)
  info = info or displays.get()
  if not info.has_external then
    return main_bar
  end
  local on_builtin = displays.on_builtin(workspace)
  if main_bar then
    return on_builtin
  end
  return not on_builtin
end

return displays
