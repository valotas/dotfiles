local colors = require("colors")

sbar.bar({
  notch_width = 0,
  height = 34,
  -- Floating island; stay below the native menu bar.
  margin = 12,
  y_offset = 3,
  corner_radius = 14,
  color = colors.bg,
  padding_left = 10,
  padding_right = 10,
  fullscreen_show = true,
  topmost = "off",
  glass = false,
})
