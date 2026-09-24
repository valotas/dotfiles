local colors = require("colors")
local displays = require("helpers.displays")

-- Same AeroSpace strip as sketchybar: number pill, app icons for the windows
-- on that workspace, and a monitor mark before the first workspace on each
-- display. Colors stay Tokyo Night.

local here = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"
local app_icons = dofile(here .. "../../sketchybar/helpers/app_icons.lua")

sbar.add("event", "aerospace_workspace_change")

local aerospace = "/opt/homebrew/bin/aerospace"
if os.execute("test -x " .. aerospace) ~= true then
  aerospace = "/usr/local/bin/aerospace"
  if os.execute("test -x " .. aerospace) ~= true then
    aerospace = "aerospace"
  end
end

local APP_FONT = "sketchybar-app-font:Regular:16.0"
local WS_FORMAT = "'%{workspace}|%{workspace-is-focused}|%{monitor-id}|%{monitor-name}|%{monitor-appkit-nsscreen-screens-id}'"
local WIN_FORMAT = "'%{workspace}|%{app-name}'"

local function split_fields(line)
  local fields = {}
  local start = 1
  while true do
    local stop = line:find("|", start, true)
    if not stop then
      fields[#fields + 1] = line:sub(start)
      break
    end
    fields[#fields + 1] = line:sub(start, stop - 1)
    start = stop + 1
  end
  return fields
end

local function lines_of(text)
  local rows = {}
  for line in (text or ""):gmatch("[^\r\n]+") do
    if line:match("%S") then
      rows[#rows + 1] = split_fields(line)
    end
  end
  return rows
end

local workspaces = {}

local function create_workspace(name)
  local monitor = sbar.add("item", "tokyonight.monitor." .. name, {
    position = "left",
    drawing = false,
    icon = {
      string = "sf:display",
      font = { size = 18 },
      color = colors.muted,
      padding_left = 2,
      -- Gap after the glyph. The label's negative padding is increased by
      -- the same amount so the digit stays put on the screen.
      padding_right = 10,
      background = { drawing = false },
    },
    label = {
      string = "",
      font = { family = "SF Pro", style = "Bold", size = 8 },
      color = colors.fg,
      padding_left = -24,
      padding_right = 22,
      y_offset = 1,
    },
  })

  local item = sbar.add("item", "tokyonight.ws." .. name, {
    position = "left",
    drawing = false,
    icon = {
      font = { family = "SF Pro", style = "Semibold", size = 13 },
      string = name,
      color = colors.fg,
      -- Glyph inset. The chip plate uses the same inset so its left edge
      -- lands on the selection border; YBar does not widen layout for
      -- background padding, only for this padding.
      padding_left = 12,
      padding_right = 12,
      background = {
        color = colors.chip,
        corner_radius = 6,
        height = 24,
        padding_left = 12,
        padding_right = 12,
      },
    },
    label = {
      color = colors.muted,
      font = APP_FONT,
      y_offset = -1,
      padding_left = 8,
      padding_right = 12,
    },
    background = {
      color = colors.transparent,
      border_color = colors.chip,
      border_width = 1,
      corner_radius = 8,
      height = 26,
    },
    padding_left = 0,
    padding_right = 6,
    click_script = aerospace .. " workspace " .. name,
  })

  workspaces[name] = { item = item, monitor = monitor }
end

for sid = 1, 9 do
  create_workspace(tostring(sid))
end

local function display_for(monitor_name, screen_id, info)
  if not info.has_external then
    return info.builtin_value or screen_id
  end
  if displays.on_builtin(monitor_name) then
    return info.builtin_value
  end
  return info.external_value or screen_id
end

local function paint(ws, focused, icons, show_monitor, monitor_id, display)
  local selected = focused
  local pill = selected and colors.with_alpha(colors.purple, 0.35) or colors.chip
  local border = selected and colors.purple or colors.chip

  ws.item:set({
    drawing = true,
    display = display,
    icon = {
      color = selected and colors.purple or colors.fg,
      padding_left = 12,
      padding_right = 12,
      background = { color = pill, padding_left = 12, padding_right = 12 },
    },
    label = {
      string = icons,
      font = APP_FONT,
      color = selected and colors.fg or colors.muted,
      padding_left = 8,
      padding_right = 12,
    },
    background = { border_color = border, border_width = 1 },
  })

  if show_monitor and monitor_id and monitor_id ~= "" then
    ws.monitor:set({
      drawing = true,
      display = display,
      label = { string = monitor_id },
    })
  else
    ws.monitor:set({ drawing = false })
  end
end

local function hide(ws)
  ws.item:set({ drawing = false })
  ws.monitor:set({ drawing = false })
end

local function refresh()
  local info = displays.get()
  sbar.exec(aerospace .. " list-workspaces --all --format " .. WS_FORMAT .. " 2>/dev/null", function(ws_out)
    sbar.exec(aerospace .. " list-windows --all --format " .. WIN_FORMAT .. " 2>/dev/null", function(win_out)
      local windows = {}
      for _, fields in ipairs(lines_of(win_out)) do
        local sid, app = fields[1], fields[2]
        if sid and app and app ~= "" then
          windows[sid] = windows[sid] or {}
          windows[sid][#windows[sid] + 1] = app
        end
      end

      local seen_monitor = {}
      local seen = {}
      for _, fields in ipairs(lines_of(ws_out)) do
        local sid = fields[1]
        local ws = sid and workspaces[sid]
        if ws then
          seen[sid] = true
          local focused = fields[2] == "true"
          local monitor_id = fields[3] or ""
          local monitor_name = fields[4] or ""
          local screen_id = fields[5] or ""
          local apps = windows[sid] or {}
          local visible = focused or #apps > 0

          if not visible then
            hide(ws)
          else
            local icons = ""
            for _, app in ipairs(apps) do
              if icons ~= "" then icons = icons .. " " end
              icons = icons .. app_icons.app_icon(app)
            end
            if icons == "" then
              icons = "_"
            end
            local show_monitor = not seen_monitor[monitor_id]
            seen_monitor[monitor_id] = true
            paint(ws, focused, icons, show_monitor, monitor_id, display_for(monitor_name, screen_id, info))
          end
        end
      end

      for sid, ws in pairs(workspaces) do
        if not seen[sid] then
          hide(ws)
        end
      end
    end)
  end)
end

local observer = sbar.add("item", "tokyonight.ws.observer", {
  drawing = false,
  updates = true,
  update_freq = 5,
})
observer:subscribe({
  "routine",
  "system_woke",
  "front_app_switched",
  "aerospace_workspace_change",
  "aerospace_focus_changed",
  "aerospace_focused_monitor_changed",
  "display_change",
}, refresh)

refresh()
