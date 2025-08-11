-- Require the sketchybar module
sbar = require("sketchybar")
local bar = require("bar")
local logging = require("helpers.logging")

-- Set the bar name, if you are using another bar instance than sketchybar
local bar_name = os.getenv("BAR_NAME")
logging.log("Setting bar name to " .. bar_name)
sbar.set_bar_name(bar_name)

-- Bundle the entire initial configuration into a single message to sketchybar
sbar.begin_config()
sbar.bar(bar.create_bar_config(bar_name))
require("default")
require("items")
sbar.end_config()

sbar.add("event", "display_change", "hs.screen.watcher")
sbar.subscribe({"display_change"}, function()
  logging.log("Display changed")
end)

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()
