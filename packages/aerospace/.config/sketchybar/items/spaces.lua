local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local logging = require("helpers.logging")
local aerospace = require("helpers.aerospace")
local json = require("helpers.json")
local icons = require("icons")

local create_workspace = function(name)
  local workspace_indicator = sbar.add("item", "workspace.indicator." .. name, {
    icon = {
      font = { family = settings.font.numbers },
      string = name,
      color = colors.white,
      padding_left = 10,
      padding_right = 10,
      background = {
        color = colors.bg2,
        corner_radius = 9,
        height = 24,
      },
    },
    label = {
      color = colors.grey,
      y_offset = -1,
      padding_right = 15
    },
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
    },
    padding_left = 0,
    padding_right = 0,
  })


  local workspace_spacer = sbar.add("item", "workspace.spacer." .. name, {
    background = {
      color = colors.transparent,
      border_width = 0,
    },
    padding_left = 0,
  })


  local set_visible = function(visible)
    workspace_indicator:set({ drawing = visible })
    workspace_spacer:set({ drawing = visible })
  end

  local set_windows = function(windows)
    local has_windows = #windows > 0
    set_visible(has_windows)

    if has_windows then
      local icons = ""
      for _, window in ipairs(windows) do
        icons = icons .. " " .. app_icons.app_icon(window.app_name)
      end
      workspace_indicator:set({ label = { string = icons, font = settings.app_font } })
    else
      workspace_indicator:set({ label = { string = icons.empty_window, font = { family = settings.font.icon_fonts, size = 16, style = settings.font.style_map["Black"] } } })
    end
  end

  local set_focused = function(focused)
    local color = focused and colors.bg2 or colors.bg1
    workspace_indicator:set({ background = { border_color = color }, icon = { background = { color = color } } })
    if focused then
      sbar.animate("sin", 0.2, function()
        set_visible(true)
      end)
    end
  end

  return {
    name = "workspace." .. name,
    set_windows = set_windows,
    set_focused = set_focused,
  }
end


local workspaces = {}
-- Simple loop to iterate from 1 to 10 and print hello
for i = 1, 9 do
  local workspace = create_workspace(i)
  workspaces[workspace.name] = workspace
end

local get_workspace_item = function(sid)
  return workspaces["workspace." .. sid]
end


local update_workspaces_container = function(results)
  for _, workspace in ipairs(results.workspaces) do
    --logging.log("workspace: " .. json.stringify(workspace))
    local workspace_item = get_workspace_item(workspace.sid)

    if workspace_item then
      workspace_item.set_windows(workspace.windows)
      workspace_item.set_focused(workspace.focused)
    end
  end
end


aerospace.list_workspaces_with_windows_async(update_workspaces_container)

local listener = sbar.add("item", "aerospace.listener", {
  drawing = false,
  updates = true,
})

listener:subscribe("aerospace_workspace_change", function(event)
  logging.log("aerospace_workspaces_updated: " .. json.stringify(event))
end)

listener:subscribe("aerospace_focus_changed", function(event)
  logging.log("aerospace_focus_changed: " .. json.stringify(event))
  aerospace.list_workspaces_with_windows_async(update_workspaces_container)
end)

listener:subscribe("aerospace_focused_monitor_changed", function(event)
  logging.log("aerospace_focused_monitor_changed: " .. json.stringify(event))
end)

