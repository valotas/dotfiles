local colors = require("colors")

-- The bar is only an icon, tinted by how much of the plan is used.
-- Each popup entry is one row: name, consumption bar, amount used.

local WIDTH = 324
local INSET = 12
local NAME_W = 110
local VALUE_W = 108
local TRACK = WIDTH - NAME_W - VALUE_W
local CODEXBAR = "/opt/homebrew/bin/codexbar"
local root = (debug.getinfo(1, "S").source:match("@?(.*/)") or "./"):gsub("items/$", "")
local parse = dofile(root .. "helpers/codexbar_usage.lua")

local icon = sbar.add("item", "tokyonight.codexbar", {
  position = "right",
  icon = {
    string = "sf:chart.bar.fill",
    color = colors.muted,
    padding_left = 4,
    padding_right = 4,
  },
  label = { drawing = false },
})

local bracket = sbar.add("bracket", "tokyonight.codexbar.bracket", { icon.name }, {
  popup = {
    align = "right",
    fade_in = 8,
    fade_out = 6,
    background = {
      color = colors.bg,
      border_color = colors.with_alpha(colors.muted, 0.55),
      border_width = 1,
      corner_radius = 16,
    },
  },
})

local popup_pos = "popup." .. bracket.name

local function row(name, opts)
  opts.position = popup_pos
  opts.width = WIDTH
  return sbar.add("item", name, opts)
end

local function meter(name, style)
  return sbar.add("slider", name, TRACK, {
    position = popup_pos,
    drawing = false,
    width = WIDTH,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = "",
      font = { size = 12, style = style or "Semibold" },
      color = colors.fg,
      align = "left",
      width = NAME_W,
      padding_left = INSET,
      padding_right = 6,
    },
    label = {
      string = "",
      font = { size = 12, style = "Semibold" },
      align = "right",
      width = VALUE_W,
      padding_left = 6,
      padding_right = INSET,
    },
    slider = {
      width = TRACK,
      percentage = 0,
      interactive = "off",
      highlight_color = colors.blue,
      background = {
        height = 4,
        corner_radius = 2,
        color = colors.chip,
      },
      knob = { drawing = false },
    },
  })
end

local cursor_head = meter("tokyonight.codexbar.cursor", "Bold")
local cursor_when = row("tokyonight.codexbar.cursor.when", {
  drawing = false,
  icon = {
    string = "",
    font = { size = 11, style = "Regular" },
    color = colors.muted,
    align = "left",
    padding_left = INSET,
  },
  label = { drawing = false },
})

local meters = {}
for i = 1, 6 do
  meters[i] = meter("tokyonight.codexbar.meter." .. i)
end

local function caption(name)
  return row(name, {
    drawing = false,
    icon = {
      string = "",
      font = { size = 11, style = "Regular" },
      color = colors.muted,
      align = "left",
      padding_left = INSET,
    },
    label = { drawing = false },
  })
end

-- Same hairline the OpenRouter block uses, so Claude sits in its own group.
local claude_rule = row("tokyonight.codexbar.claude.rule", {
  drawing = false,
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    drawing = true,
    height = 1,
    color = colors.with_alpha(colors.muted, 0.4),
  },
})

local claude_title = row("tokyonight.codexbar.claude", {
  drawing = false,
  padding_top = 6,
  padding_bottom = 2,
  icon = {
    string = "",
    font = { size = 12, style = "Bold" },
    color = colors.fg,
    align = "left",
    padding_left = INSET,
  },
  label = { drawing = false },
})

-- Session and weekly are both the plan headline: bold name, bar, percent, reset.
local claude_session = meter("tokyonight.codexbar.claude.session", "Bold")
local claude_session_when = caption("tokyonight.codexbar.claude.session.when")
local claude_weekly = meter("tokyonight.codexbar.claude.weekly", "Bold")
local claude_weekly_when = caption("tokyonight.codexbar.claude.weekly.when")

local gap = row("tokyonight.codexbar.gap", {
  drawing = false,
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    drawing = true,
    height = 1,
    color = colors.with_alpha(colors.muted, 0.4),
  },
})

local credits = meter("tokyonight.codexbar.credits", "Bold")

local line_foot = row("tokyonight.codexbar.line.foot", {
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    drawing = true,
    height = 1,
    color = colors.with_alpha(colors.muted, 0.4),
  },
})

local opener = row("tokyonight.codexbar.open", {
  padding_top = 4,
  padding_bottom = 8,
  icon = {
    string = "Open CodexBar",
    font = { size = 12.5, style = "Semibold" },
    color = colors.blue,
    align = "left",
    width = WIDTH - 36,
    padding_left = INSET,
  },
  label = {
    string = "›",
    font = { size = 18 },
    color = colors.blue,
    align = "right",
    width = 36,
    padding_right = INSET,
  },
})

local FETCH = "tmp=$(mktemp -d)\n"
  .. CODEXBAR .. " usage --provider cursor --format json >\"$tmp/cursor\" 2>/dev/null &\n"
  .. CODEXBAR .. " usage --provider claude --format json >\"$tmp/claude\" 2>/dev/null &\n"
  .. CODEXBAR .. " usage --provider openrouter --format json >\"$tmp/openrouter\" 2>/dev/null &\n"
  .. "wait || true\n"
  .. "printf '%s\\n' '---CURSOR---'\n"
  .. "cat \"$tmp/cursor\"\n"
  .. "printf '\\n%s\\n' '---CLAUDE---'\n"
  .. "cat \"$tmp/claude\"\n"
  .. "printf '\\n%s\\n' '---OPENROUTER---'\n"
  .. "cat \"$tmp/openrouter\"\n"
  .. "printf '\\n'\n"
  .. "rm -rf \"$tmp\"\n"

-- Blue and purple match the other right-side icons. Red is the
-- same "this is used up" signal as a low battery. The gold yellow
-- is in the palette, but it reads warm next to those blues.
local function usage_color(used)
  if type(used) ~= "number" then
    return colors.blue
  end
  if used >= 95 then
    return colors.red
  end
  if used >= 80 then
    return colors.purple
  end
  return colors.blue
end

local function caption_color(compact)
  if compact == "now" or (compact ~= "" and compact:match("[hm]$")) then
    return colors.purple
  end
  return colors.muted
end

local function soften(sentence)
  if sentence == "" then
    return ""
  end
  return sentence:sub(1, 1):lower() .. sentence:sub(2)
end

local function context_line(sentence, pace)
  local when = soften(sentence or "")
  local short = (pace or ""):match("^[^·]+")
  if short then
    short = short:gsub("^%s+", ""):gsub("%s+$", "")
  end
  if when ~= "" and short and short ~= "" then
    return when .. " · " .. short:lower()
  end
  if when ~= "" then
    return when
  end
  return short or ""
end

local function paint_meter(slot, entry)
  if not entry then
    slot:set({ drawing = false })
    return
  end
  local color = usage_color(entry.used)
  local fill = entry.fill
  slot:set({
    drawing = true,
    icon = { string = entry.title },
    label = { string = entry.value, color = color },
    slider = {
      percentage = math.max(0, math.min(100, fill or 0)),
      highlight_color = color,
    },
  })
end

local function paint_window(slot, when, stat)
  if not stat then
    slot:set({ drawing = false })
    when:set({ drawing = false })
    return false
  end
  paint_meter(slot, stat)
  local line = context_line(stat.sentence, stat.pace)
  when:set({
    drawing = line ~= "",
    icon = { string = line, color = caption_color(stat.compact or "") },
  })
  return true
end

local function peak_used(...)
  local peak
  for i = 1, select("#", ...) do
    local n = select(i, ...)
    if type(n) == "number" and (not peak or n > peak) then
      peak = n
    end
  end
  return peak
end

local function apply(out)
  if not out or out:match("^%s*$") then
    return
  end

  local cursor_raw = out:match("---CURSOR---\n(.-)\n---CLAUDE---")
  local claude_raw = out:match("---CLAUDE---\n(.-)\n---OPENROUTER---")
  local or_raw = out:match("---OPENROUTER---\n(.*)")
  local parsed = parse(cursor_raw, or_raw, claude_raw)
  if not parsed then
    return
  end

  local has_plan = type(parsed.used) == "number"
  local credit_row = parsed.credits
  local claude = parsed.claude

  if has_plan then
    paint_meter(cursor_head, {
      title = parsed.plan ~= "" and parsed.plan or "Cursor",
      used = parsed.used,
      fill = math.min(100, parsed.used),
      value = parsed.used .. "%",
    })
    local line = context_line(parsed.sentence, parsed.pace)
    cursor_when:set({
      drawing = line ~= "",
      icon = { string = line, color = caption_color(parsed.compact or "") },
    })
    for i, slot in ipairs(meters) do
      paint_meter(slot, parsed.rows[i])
    end
  else
    paint_meter(cursor_head, nil)
    cursor_when:set({ drawing = false })
    for _, slot in ipairs(meters) do
      paint_meter(slot, nil)
    end
  end

  local session_on = paint_window(claude_session, claude_session_when, claude and claude.session)
  local weekly_on = paint_window(claude_weekly, claude_weekly_when, claude and claude.weekly)
  local has_claude = session_on or weekly_on
  claude_title:set({
    drawing = has_claude,
    icon = { string = (claude and claude.plan ~= "" and claude.plan) or "Claude" },
  })
  claude_rule:set({ drawing = has_plan and has_claude })

  paint_meter(credits, credit_row)

  local peak = peak_used(
    has_plan and parsed.used or nil,
    claude and claude.session and claude.session.used or nil,
    claude and claude.weekly and claude.weekly.used or nil
  )
  if peak then
    icon:set({ icon = { color = usage_color(peak) } })
  else
    icon:set({
      icon = { color = credit_row and usage_color(credit_row.used) or colors.muted },
    })
  end

  gap:set({ drawing = credit_row ~= nil and (has_plan or has_claude) })
  line_foot:set({ drawing = has_plan or has_claude or credit_row ~= nil })
end

local function refresh()
  sbar.exec(FETCH, apply)
end

local function popup_open()
  local popup = bracket:query().popup
  return popup and popup.drawing == "on"
end

local opened_at = 0

local function show()
  if popup_open() then
    return
  end
  opened_at = os.clock()
  refresh()
  bracket:set({ popup = { drawing = true } })
end

local function hide()
  bracket:set({ popup = { drawing = false } })
end

-- Hover opens it. A click on the icon does too, and a later click closes
-- it. The click that lands in the same moment as the hover must not
-- immediately toggle the card shut.
local function toggle()
  if popup_open() and (os.clock() - opened_at) > 0.35 then
    hide()
  else
    show()
  end
end

icon:subscribe("mouse.entered", show)
icon:subscribe("mouse.clicked", toggle)
icon:subscribe("mouse.exited.global", hide)

opener:subscribe("mouse.clicked", function()
  sbar.exec("open -a CodexBar")
  bracket:set({ popup = { drawing = false } })
end)
