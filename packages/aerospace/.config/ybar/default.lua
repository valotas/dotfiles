local colors = require("colors")

sbar.default({
  updates = "when_shown",
  icon = {
    font = { family = "SF Pro", style = "Semibold", size = 12.5 },
    color = colors.fg,
    padding_left = 4,
    padding_right = 4,
  },
  label = {
    font = { family = "SF Pro", style = "Semibold", size = 12.5 },
    color = colors.fg,
    padding_left = 2,
    padding_right = 4,
  },
  background = {
    drawing = false,
    corner_radius = 8,
    height = 22,
  },
  padding_left = 2,
  padding_right = 2,
})
