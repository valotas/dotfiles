-- Tokyo Night overlay: full-width strip, accent text, per-display
-- AeroSpace pills, clock position, and input-source. Native menu bar stays
-- on top (topmost=off). Sketchybar configs stay in place.

local config_dir = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"

local function first_port(paths)
  for _, path in ipairs(paths) do
    local probe = io.open(path .. "/sketchybar.lua", "r")
    if probe then
      probe:close()
      return path
    end
  end
end

PORT_DIR = first_port({
  config_dir .. "themes/sketchybar-port",
  os.getenv("HOME") .. "/.config/ybar/themes/sketchybar-port",
  "/opt/homebrew/share/ybar/examples/sketchybar-port",
  "/usr/local/share/ybar/examples/sketchybar-port",
})

if not PORT_DIR then
  error("YBar sketchybar-port theme not found. Install ybar or clone examples into ~/.config/ybar/themes/sketchybar-port")
end

SKETCHYBAR_CONFIG = PORT_DIR

package.path = config_dir .. "?.lua;"
  .. config_dir .. "?/init.lua;"
  .. PORT_DIR .. "/?.lua;"
  .. PORT_DIR .. "/?/init.lua;"
  .. package.path

sbar = require("sketchybar")

sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

sbar.event_loop()
