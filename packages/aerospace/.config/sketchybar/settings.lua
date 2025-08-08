
-- This is a font configuration for SF Pro and SF Mono (installed manually)
local font = require("helpers.default_font")

return {
  paddings = 3,
  group_paddings = 0,
  font = font,
  icons = "NerdFonts",
  app_font = font.app_fonts .. ":Regular:16.0",
}

