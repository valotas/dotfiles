local main_dark = 0xff1E1E2E

local with_alpha = function(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then return color end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return {
  black = 0xff181819,
  white = 0xffCDD6F4,
  grey = 0xff56678f,
  transparent = 0x00000000,

  bar = {
    bg = with_alpha(main_dark, 0.9),
  },
  popup = {
    bg = 0xc01E1E2E,
    border = 0xff7f8490
  },
  bg1 = 0xff2A2E3F,
  bg2 = 0xff37405d,

  with_alpha = with_alpha,
}
