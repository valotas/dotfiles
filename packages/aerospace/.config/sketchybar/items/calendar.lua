local settings = require("settings")
local colors = require("colors")

local bar_name = os.getenv("BAR_NAME")
local cal = sbar.add("item", {
  label = {
    color = colors.white,
    padding_right = 8,
    align = "right",
    font = { family = settings.font.numbers, style = settings.font.style_map["Black"] },
  },
  position = bar_name == "sketchybar_main" and "right" or "center",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  click_script = "open -a 'Calendar'"
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({ label = os.date("%a %d/%m %H:%M") })
end)
