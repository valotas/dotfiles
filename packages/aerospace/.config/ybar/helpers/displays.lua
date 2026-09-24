local displays = {}

-- Built-in MacBook panel. Any other UUID is treated as an external.
local BUILTIN_UUID = "37D8832A-2D66-02CA-B9F7-8F30A301B230"

local AEROSPACE = "/opt/homebrew/bin/aerospace"
if os.execute("test -x " .. AEROSPACE) ~= true then
  AEROSPACE = "/usr/local/bin/aerospace"
  if os.execute("test -x " .. AEROSPACE) ~= true then
    AEROSPACE = "aerospace"
  end
end

local function as_id(value)
  if value == nil then
    return nil
  end
  return tostring(value)
end

local function join(ids)
  if #ids == 0 then
    return nil
  end
  return table.concat(ids, ",")
end

function displays.on_builtin(monitor_name)
  local name = string.lower(tostring(monitor_name or ""))
  return name:find("built%-in", 1) ~= nil
end

local function from_aerospace()
  local builtin, externals = {}, {}
  local handle = io.popen(
    AEROSPACE .. " list-monitors --format '%{monitor-name}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null"
  )
  if not handle then
    return builtin, externals
  end
  for line in handle:lines() do
    local name, id = line:match("^(.-)|(.+)$")
    id = as_id(id and id:gsub("%s+", ""))
    if id and id ~= "" then
      if displays.on_builtin(name) then
        table.insert(builtin, id)
      else
        table.insert(externals, id)
      end
    end
  end
  handle:close()
  return builtin, externals
end

local function from_ybar()
  local queried = sbar.query("displays") or {}
  local builtin, externals = {}, {}
  local list = queried[1] and queried or {}
  if queried[1] then
    list = queried
  else
    list = {}
    for _, display in pairs(queried) do
      table.insert(list, display)
    end
  end

  local saw_uuid = false
  for _, display in ipairs(list) do
    if type(display) == "table" and display.UUID then
      saw_uuid = true
      local display_id = as_id(display["arrangement-id"])
      if display_id then
        if display.UUID == BUILTIN_UUID then
          table.insert(builtin, display_id)
        else
          table.insert(externals, display_id)
        end
      end
    end
  end

  if saw_uuid then
    return builtin, externals
  end

  -- No UUID: pick the smallest display as the laptop panel.
  local smallest, smallest_area
  for _, display in ipairs(list) do
    if type(display) == "table" and display.frame then
      local area = (display.frame.w or 0) * (display.frame.h or 0)
      if area > 0 and (not smallest_area or area < smallest_area) then
        smallest = display
        smallest_area = area
      end
    end
  end
  for _, display in ipairs(list) do
    local display_id = as_id(display["arrangement-id"])
    if display_id then
      if display == smallest then
        table.insert(builtin, display_id)
      else
        table.insert(externals, display_id)
      end
    end
  end
  return builtin, externals
end

function displays.get()
  local builtin, externals = from_aerospace()
  if #builtin == 0 and #externals == 0 then
    builtin, externals = from_ybar()
  end
  return {
    builtin = builtin,
    externals = externals,
    builtin_value = join(builtin),
    external_value = join(externals),
    has_external = #externals > 0,
  }
end

return displays
