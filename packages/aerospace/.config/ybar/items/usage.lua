local colors = require("colors")

-- CodexBar's menu cannot live inside the bar. This popup shows the same
-- Overview numbers CodexBar already fetched: Cursor meters and the
-- OpenRouter balance. A click opens it; the last row opens CodexBar itself.

local WIDTH = 280
local CODEXBAR = "/opt/homebrew/bin/codexbar"
local PYTHON = "/opt/homebrew/bin/python3"

local pill = sbar.add("item", "tokyonight.codexbar", {
  position = "right",
  update_freq = 120,
  updates = true,
  icon = { string = "sf:chart.bar.fill", color = colors.purple },
  image = { drawing = false },
  label = { drawing = false },
})

local bracket = sbar.add("bracket", "tokyonight.codexbar.bracket", { pill.name }, {
  popup = {
    align = "right",
    background = {
      color = colors.bg,
      border_color = colors.chip,
      border_width = 1,
      corner_radius = 12,
    },
  },
})

local popup_pos = "popup." .. bracket.name

local function row(name, opts)
  opts.position = popup_pos
  opts.width = WIDTH
  return sbar.add("item", name, opts)
end

local header = row("tokyonight.codexbar.header", {
  icon = {
    string = "Usage",
    font = { size = 14, style = "Bold" },
    color = colors.fg,
    padding_left = 12,
  },
  label = { drawing = false },
})

local plan = row("tokyonight.codexbar.plan", {
  icon = {
    string = "Cursor",
    font = { size = 12, style = "Semibold" },
    color = colors.fg,
    padding_left = 12,
  },
  label = {
    string = "",
    color = colors.muted,
    font = { size = 12 },
    padding_right = 12,
  },
})

local reset = row("tokyonight.codexbar.reset", {
  icon = {
    string = "",
    font = { size = 11 },
    color = colors.muted,
    padding_left = 12,
  },
  label = { drawing = false },
})

local function meter(name)
  return sbar.add("slider", name, 110, {
    position = popup_pos,
    width = WIDTH,
    icon = {
      string = "",
      font = { size = 12 },
      color = colors.fg,
      padding_left = 12,
      width = 110,
      align = "left",
    },
    slider = {
      percentage = 0,
      highlight_color = colors.green,
      background = {
        height = 6,
        corner_radius = 3,
        color = colors.chip,
      },
      knob = { drawing = false },
    },
    label = {
      string = "",
      font = { size = 12 },
      color = colors.fg,
      align = "right",
      width = 44,
      padding_right = 12,
    },
  })
end

local meters = {}
for i = 1, 6 do
  meters[i] = meter("tokyonight.codexbar.meter." .. i)
end

local openrouter = row("tokyonight.codexbar.openrouter", {
  icon = {
    string = "OpenRouter",
    font = { size = 12, style = "Semibold" },
    color = colors.fg,
    padding_left = 12,
  },
  label = {
    string = "",
    color = colors.muted,
    font = { size = 12 },
    padding_right = 12,
  },
})

row("tokyonight.codexbar.open", {
  icon = {
    string = "Open CodexBar",
    font = { size = 12 },
    color = colors.blue,
    padding_left = 12,
  },
  label = { drawing = false },
  click_script = "open -a CodexBar",
})

local FETCH = [[
CURSOR=$(]] .. CODEXBAR .. [[ usage --provider cursor --format json 2>/dev/null || true)
ORJSON=$(]] .. CODEXBAR .. [[ usage --provider openrouter --format json 2>/dev/null || true)
CURSOR_JSON="$CURSOR" OR_JSON="$ORJSON" ]] .. PYTHON .. [[ -c '
import json, os
def first(raw):
    raw = (raw or "").strip()
    if not raw:
        return None
    try:
        data = json.loads(raw)
    except Exception:
        return None
    return data[0] if isinstance(data, list) and data else data
def pct(window):
    if not isinstance(window, dict) or window.get("usedPercent") is None:
        return None
    return int(round(float(window["usedPercent"])))
c = first(os.environ.get("CURSOR_JSON"))
if c:
    u = c.get("usage") or {}
    labels = c.get("rateWindowLabels") or {}
    ident = u.get("identity") or {}
    plan = ident.get("loginMethod") or "Cursor"
    print("plan\t" + plan)
    reset = (u.get("primary") or {}).get("resetDescription") or ""
    if reset:
        print("reset\t" + reset)
    rows = [
        (labels.get("primary") or "Total", pct(u.get("primary"))),
        (labels.get("secondary") or "Cursor", pct(u.get("secondary"))),
        (labels.get("tertiary") or "Third Party", pct(u.get("tertiary"))),
    ]
    for extra in u.get("extraRateWindows") or []:
        window = extra.get("window") if isinstance(extra.get("window"), dict) else extra
        rows.append((extra.get("title") or "Extra", pct(window)))
    for title, used in rows:
        if used is not None:
            print("meter\t%s\t%d" % (title, used))
o = first(os.environ.get("OR_JSON"))
if o:
    u = o.get("usage") or {}
    balance = (u.get("identity") or {}).get("loginMethod") or ""
    if balance.lower().startswith("balance:"):
        balance = balance.split(":", 1)[1].strip()
    if balance:
        print("balance\t" + balance)
'
]]

local function apply(out)
  local plan_name, reset_text, balance = "", "", ""
  local rows = {}
  for line in (out or ""):gmatch("[^\n]+") do
    local kind, rest = line:match("^(%w+)\t(.*)$")
    if kind == "plan" then
      plan_name = rest
    elseif kind == "reset" then
      reset_text = rest
    elseif kind == "balance" then
      balance = rest
    elseif kind == "meter" then
      local title, used = rest:match("^(.-)\t(%d+)$")
      if title then
        rows[#rows + 1] = { title = title, used = tonumber(used) }
      end
    end
  end

  plan:set({
    drawing = plan_name ~= "",
    icon = { string = "Cursor" },
    label = { string = plan_name },
  })
  reset:set({
    drawing = reset_text ~= "",
    icon = { string = reset_text },
  })
  openrouter:set({
    drawing = balance ~= "",
    label = { string = balance },
  })
  for i, item in ipairs(meters) do
    local entry = rows[i]
    if entry then
      item:set({
        drawing = true,
        icon = { string = entry.title },
        label = { string = entry.used .. "%" },
        slider = { percentage = entry.used },
      })
    else
      item:set({ drawing = false })
    end
  end
end

local function refresh()
  sbar.exec(FETCH, apply)
end

local function popup_open()
  local popup = bracket:query().popup
  return popup and popup.drawing == "on"
end

pill:subscribe("mouse.clicked", function()
  if popup_open() then
    bracket:set({ popup = { drawing = false } })
  else
    refresh()
    bracket:set({ popup = { drawing = true } })
  end
end)
pill:subscribe("mouse.exited.global", function()
  bracket:set({ popup = { drawing = false } })
end)
pill:subscribe({ "routine", "forced", "system_woke" }, refresh)
refresh()
