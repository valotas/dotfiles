local sbar = require("sbar")

hs.keycodes.inputSourceChanged(function()
  sbar.trigger("input_source_change")
end)
