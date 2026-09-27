-- Read CodexBar's JSON in-process. The slow part is the fetch, not this parse.

local here = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"
local json = dofile(here .. "../../sketchybar/helpers/json.lua")

local function present(value)
  return type(value) == "table" and value ~= json.null
end

local function decode(raw)
  if type(raw) ~= "string" or raw:match("^%s*$") then
    return nil
  end
  local ok, data = pcall(json.parse, raw)
  if not ok or not present(data) then
    return nil
  end
  local payload = data[1]
  if payload == nil then
    payload = (data.usage or data.provider) and data or nil
  end
  if not present(payload) then
    return nil
  end
  if present(payload.error) then
    return nil
  end
  return payload
end

local function parse_utc(iso)
  if type(iso) ~= "string" then
    return nil
  end
  local y, mo, d, h, mi, s = iso:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)")
  if not y then
    return nil
  end
  local as_local = os.time({
    year = tonumber(y),
    month = tonumber(mo),
    day = tonumber(d),
    hour = tonumber(h),
    min = tonumber(mi),
    sec = tonumber(s),
  })
  if not as_local then
    return nil
  end
  local z = os.date("%z", as_local)
  local sign = z:sub(1, 1) == "-" and -1 or 1
  local offset = sign * ((tonumber(z:sub(2, 3)) or 0) * 3600 + (tonumber(z:sub(4, 5)) or 0) * 60)
  return as_local + offset
end

local function noon(epoch)
  local t = os.date("*t", epoch)
  return os.time({ year = t.year, month = t.month, day = t.day, hour = 12 })
end

-- Compact is 2d / 6h / 40m / now. The sentence is what the popup shows.
local function countdown(iso)
  local moment = parse_utc(iso)
  if not moment then
    return "", ""
  end
  local secs = os.difftime(moment, os.time())
  local clock = os.date("%a %H:%M", moment)
  local weekday, hm = clock:match("^(%S+)%s+(.+)$")
  if secs <= 90 then
    return "now", "Resets now"
  end
  if secs < 86400 then
    if secs >= 3600 then
      local n = math.max(1, math.floor(secs / 3600 + 0.5))
      local unit = n == 1 and "hour" or "hours"
      local sentence = string.format("In %d %s", n, unit)
      if hm then
        sentence = sentence .. " · " .. hm
      end
      return n .. "h", sentence
    end
    local n = math.max(1, math.floor(secs / 60 + 0.5))
    local sentence = string.format("In %d min", n)
    if hm then
      sentence = sentence .. " · " .. hm
    end
    return n .. "m", sentence
  end
  local day_delta = math.floor(os.difftime(noon(moment), noon(os.time())) / 86400 + 0.5)
  if day_delta <= 1 then
    if hm then
      return "1d", "Tomorrow at " .. hm
    end
    return "1d", "Tomorrow"
  end
  if weekday and hm then
    return day_delta .. "d", string.format("In %d days · %s %s", day_delta, weekday, hm)
  end
  return day_delta .. "d", string.format("In %d days", day_delta)
end

local function pct(window)
  if not present(window) or type(window.usedPercent) ~= "number" then
    return nil
  end
  return math.floor(window.usedPercent + 0.5)
end

local function plain(text)
  return tostring(text):gsub("[\t\n]", " ")
end

local function money(amount, symbol)
  local rounded = math.floor(amount + 0.5)
  if math.abs(amount - rounded) < 0.001 then
    return string.format("%s%d", symbol, rounded)
  end
  return string.format("%s%.2f", symbol, amount)
end

local function currency(code)
  if code == nil or code == "USD" then
    return "$"
  end
  return tostring(code) .. " "
end

-- The bar is how much of the window has been consumed.
local function used_row(title, used, suffix)
  local value = used .. "%"
  if suffix and suffix ~= "" then
    value = value .. " · " .. suffix
  end
  return {
    title = title,
    used = math.min(100, used),
    fill = math.min(100, math.max(0, used)),
    value = value,
  }
end

local function pace_view(pace)
  if not present(pace) then
    return "", "muted"
  end
  local primary = present(pace.primary) and pace.primary or pace
  if not present(primary) or type(primary.deltaPercent) ~= "number" then
    return "", "muted"
  end
  local n = math.floor(math.abs(primary.deltaPercent) + 0.5)
  local stage = primary.stage
  if n == 0 or stage == "onpace" or stage == "on_pace" or stage == "even" then
    return "On pace", "good"
  end
  if primary.deltaPercent < 0 or stage == "behind" then
    local line = n .. "% in reserve"
    if primary.willLastToReset == true then
      line = line .. " · lasts until reset"
    end
    return line, "good"
  end
  local tone = primary.willLastToReset == false and "bad" or "warn"
  return n .. "% ahead of pace", tone
end

local function cursor_view(payload)
  local usage = payload.usage
  if not present(usage) then
    return nil
  end
  local labels = present(payload.rateWindowLabels) and payload.rateWindowLabels or {}
  local identity = present(usage.identity) and usage.identity or {}
  local plan = identity.loginMethod or usage.loginMethod or "Cursor"
  local primary = present(usage.primary) and usage.primary or {}
  local compact, sentence = countdown(primary.resetsAt)
  if sentence == "" then
    local desc = primary.resetDescription
    if type(desc) == "string" and desc ~= "" then
      sentence = plain(desc)
    end
  end

  local windows = {
    { labels.secondary or "Cursor", usage.secondary },
    { labels.tertiary or "Third Party", usage.tertiary },
  }
  if present(usage.extraRateWindows) then
    for _, extra in ipairs(usage.extraRateWindows) do
      if present(extra) then
        local window = present(extra.window) and extra.window or extra
        windows[#windows + 1] = { extra.title or "Extra", window }
      end
    end
  end

  local rows = {}
  for _, pair in ipairs(windows) do
    local used = pct(pair[2])
    if used then
      local window = present(pair[2]) and pair[2] or {}
      local row_compact = countdown(window.resetsAt)
      local suffix = ""
      if row_compact ~= "" and row_compact ~= compact then
        suffix = row_compact
      end
      rows[#rows + 1] = used_row(plain(pair[1]), used, suffix)
    end
  end

  local cost = usage.providerCost
  if present(cost) and type(cost.used) == "number" and type(cost.limit) == "number" and cost.limit > 0 then
    local symbol = currency(cost.currencyCode)
    local ratio = math.floor(cost.used / cost.limit * 100 + 0.5)
    local shown = math.min(100, math.max(0, ratio))
    rows[#rows + 1] = {
      title = "On-demand",
      used = shown,
      fill = shown,
      value = money(cost.used, symbol) .. " / " .. money(cost.limit, symbol),
    }
  end

  local pace, pace_tone = pace_view(payload.pace)
  return {
    plan = plain(plan),
    used = pct(primary),
    sentence = sentence,
    compact = compact,
    pace = pace,
    pace_tone = pace_tone,
    rows = rows,
  }
end

local function tidy_money(text)
  if type(text) ~= "string" then
    return ""
  end
  return plain(text):gsub("%.00", "")
end

local function amount_of(text)
  if type(text) ~= "string" then
    return nil
  end
  return tonumber((text:gsub("[^%d.%-]", "")))
end

local function openrouter_view(payload)
  local usage = payload.usage
  if not present(usage) then
    return nil
  end
  local remaining, spent, total
  if present(usage.details) then
    for _, block in ipairs(usage.details) do
      if present(block) and block.title == "Credits" and present(block.rows) then
        for _, detail in ipairs(block.rows) do
          if present(detail) then
            if detail.label == "Remaining" then remaining = detail.value end
            if detail.label == "Used" then spent = detail.value end
            if detail.label == "Total added" then total = detail.value end
          end
        end
      end
    end
  end

  -- Credits are a balance: the bar and the figure are what is left.
  -- `used` only picks the warning color as that balance runs down.
  local spent_n = amount_of(spent)
  local total_n = amount_of(total)
  local remain_n = amount_of(remaining)
  if not remain_n and spent_n and total_n then
    remain_n = math.max(0, total_n - spent_n)
  end

  local value = tidy_money(remaining)
  if value == "" then
    local identity = present(usage.identity) and usage.identity or {}
    local balance = identity.loginMethod or usage.loginMethod or ""
    if type(balance) == "string" and balance:lower():sub(1, 8) == "balance:" then
      value = tidy_money(balance:sub(9))
    end
  end
  if value == "" then
    return nil
  end
  if not value:find("left", 1, true) then
    value = value .. " left"
  end

  local used, fill
  if remain_n and total_n and total_n > 0 then
    fill = math.max(0, math.min(100, math.floor(remain_n / total_n * 100 + 0.5)))
    used = math.min(100, 100 - fill)
  end

  return {
    title = "OpenRouter",
    used = used,
    fill = fill,
    value = value,
  }
end

local function parse(cursor_raw, or_raw)
  local cursor = decode(cursor_raw)
  local router = decode(or_raw)
  if not cursor and not router then
    return nil
  end
  local view = cursor and cursor_view(cursor) or nil
  return {
    plan = view and view.plan or "",
    used = view and view.used or nil,
    sentence = view and view.sentence or "",
    compact = view and view.compact or "",
    pace = view and view.pace or "",
    pace_tone = view and view.pace_tone or "muted",
    rows = view and view.rows or {},
    credits = router and openrouter_view(router) or nil,
  }
end

return parse
