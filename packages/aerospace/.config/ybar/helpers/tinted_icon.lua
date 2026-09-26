-- App icons recolored to a single hue. YBar can grey a color image, but it
-- cannot tint one, so callers draw the cached bitmap instead.
local M = {}

local here = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"
local tint_src = here .. "tint_app_icon.m"
local cache_root = os.getenv("HOME") .. "/.cache/ybar"
local tint_bin = cache_root .. "/bin/tint_app_icon"
local icon_dir = cache_root .. "/app-icons"

local function quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function file_exists(path)
  local handle = io.open(path, "r")
  if not handle then
    return false
  end
  handle:close()
  return true
end

local function ensure_tinter()
  os.execute("mkdir -p " .. quote(cache_root .. "/bin") .. " " .. quote(icon_dir))
  local fresh = os.execute(string.format(
    "test -x %s -a %s -nt %s",
    quote(tint_bin), quote(tint_bin), quote(tint_src)
  )) == true
  if fresh then
    return true
  end
  return os.execute(string.format(
    "/usr/bin/clang -fobjc-arc -framework AppKit -O2 -o %s %s",
    quote(tint_bin), quote(tint_src)
  )) == true
end

function M.path(bundle, argb)
  if bundle == nil or bundle == "" or not ensure_tinter() then
    return nil
  end
  local red = (argb >> 16) & 0xff
  local green = (argb >> 8) & 0xff
  local blue = argb & 0xff
  local safe = bundle:gsub("[^%w]", "_")
  local out = string.format("%s/%s-%02x%02x%02x.png", icon_dir, safe, red, green, blue)
  if not file_exists(out) then
    os.execute(string.format(
      "%s %s %s %d %d %d >/dev/null 2>&1",
      quote(tint_bin), quote(bundle), quote(out), red, green, blue
    ))
  end
  if file_exists(out) then
    return out
  end
  return nil
end

return M
