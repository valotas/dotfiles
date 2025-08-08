local settings = require("settings")
local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local cal = sbar.add("item", {
  label = {
    color = colors.white,
    padding_right = 8,
    align = "right",
    font = { family = settings.font.numbers, style = settings.font.style_map["Black"] },
  },
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  click_script = "open -a 'Calendar'"
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({ label = os.date("%Y-%m-%d") .. " " .. os.date("%H:%M") })
end)
