local sauce = "SauceCodePro Nerd Font"
local mono =  sauce .. " Mono"

return {
  text = sauce,
  mono = mono,
  numbers = mono, -- Used for numbers
  icon_fonts = sauce,
  app_fonts = "sketchybar-app-font",

  -- Unified font style map
  style_map = {
    ["Regular"] = "Regular",
    ["Semibold"] = "Semibold",
    ["Bold"] = "Bold",
    ["Heavy"] = "Heavy",
    ["Black"] = "Black",
  }
}
