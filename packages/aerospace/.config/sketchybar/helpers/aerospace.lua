local json = require("helpers.json")
local logging = require("helpers.logging")
local aerospace = {}

local function parse_lines(s)
  local result = {}
  for line in s:gmatch("([^\n]+)") do
    if line:match("%S") then  -- Only add non-empty lines
      table.insert(result, line)
    end
  end
  return result
end

local function parse_simple_format(text, separator)
  separator = separator or "%s+"  -- Default to one or more spaces
  local result = {}
  for line in text:gmatch("([^\n]+)") do
    if line:match("%S") then  -- Only process non-empty lines
      local fields = {}
      for field in line:gmatch("([^" .. separator .. "]+)") do
        table.insert(fields, field)
      end
      table.insert(result, fields)
    end
  end
  return result
end

function aerospace.list_workspaces_async(cb)
  sbar.exec("aerospace list-workspaces --all", function(result)
    cb(parse_lines(result))
  end)
end

local function parse_workspace_line(fields)
  return {
    sid = fields[1],
    focused = fields[2] == "true",
    visible = fields[3] == "true",
    monitor_id = fields[4],
    monitor_name = fields[5],
  }
end

local function parse_window_line(fields)
  return {
    sid = fields[1],
    workspace = fields[1],
    app_name = fields[2],
    window_id = fields[3],
    monitor_id = fields[4],
    workspace_is_visible = fields[5] == "true",
    monitor_name = fields[6],
  }
end

function aerospace.list_workspaces_with_windows_async(cb)
  -- Use simple space-separated format instead of complex CSV
  sbar.exec("aerospace list-workspaces --all --format '%{workspace}|%{workspace-is-focused}|%{workspace-is-visible}|%{monitor-id}|%{monitor-name}'", function(workspaces_raw)
    sbar.exec("aerospace list-windows --all --format '%{workspace}|%{app-name}|%{window-id}|%{monitor-id}|%{workspace-is-visible}|%{monitor-name}'", function(windows_raw)
      local workspace_lines = parse_simple_format(workspaces_raw, "|")
      --logging.log("workspaces_lines: " .. json.stringify(workspace_lines))
      local window_lines = parse_simple_format(windows_raw, "|")
      logging.log("windows_lines: " .. json.stringify(window_lines))

      local workspaces = {}
      for _, fields in ipairs(workspace_lines) do
        local workspace = parse_workspace_line(fields)
        workspace.windows = {}
        table.insert(workspaces, workspace)
      end
      
      local windows = {}
      for _, fields in ipairs(window_lines) do
        local window = parse_window_line(fields)
        table.insert(windows, window)

        -- Add window to its workspace
        local workspace_id = tonumber(window.sid)
        if workspace_id and workspaces[workspace_id] then
          table.insert(workspaces[workspace_id].windows, {
            app_name = window.app_name,
            window_id = window.window_id,
          })
        end
      end

      local result = {
        workspaces = workspaces,
        windows = windows,
      }

      cb(result)
    end)
  end)
end

return aerospace