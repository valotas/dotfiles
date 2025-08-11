local sbar = require("sbar")

hs.screen.watcher.new(function()
  sbar.trigger("display_change")
end):start()

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function(e)
  sbar.trigger("display_change")
end)