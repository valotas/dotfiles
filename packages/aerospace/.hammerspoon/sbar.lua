local sbar = {}

sbar.trigger = function (event)
  --print("sketcybar --trigger " .. event)
  hs.execute("/opt/homebrew/bin/sketchybar_main --trigger " .. event)
  hs.execute("/opt/homebrew/bin/sketchybar_alternative --trigger " .. event)


  -- for reasons that are not clear to me (At least not yet) the bellow thing seems not to be working
  --hs.distributednotifications.post("com.valotas.hs.input_source_change", "com.valotas.hs", {
  --  currentLayout = layout,
  --})
end

return sbar