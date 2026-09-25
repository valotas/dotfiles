local colors = require("colors")

sbar.bar({
  notch_width = 0,
  height = 38,
  -- Full-width strip. A window margin, y_offset, or corner radius leaves
  -- gaps at the top and side edges.
  margin = 0,
  y_offset = 0,
  corner_radius = 0,
  color = colors.bg,
  padding_left = 10,
  padding_right = 10,
  fullscreen_show = true,
  topmost = "off",
  glass = false,
})
