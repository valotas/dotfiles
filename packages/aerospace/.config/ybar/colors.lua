-- Tokyo Night palette — from folke/tokyonight.nvim ("night" variant).
local colors = {
  bg     = 0xf01a1b26,
  fg     = 0xffc0caf5,
  blue   = 0xff7aa2f7,
  purple = 0xffbb9af7,
  green  = 0xff9ece6a,
  red    = 0xfff7768e,
  muted  = 0xff565f89,
  chip   = 0xff2f334d,
  transparent = 0x00000000,
}

colors.white = colors.fg
colors.black = 0xff1a1b26
colors.grey = colors.muted
colors.yellow = 0xffe0af68
colors.orange = 0xffff9e64
colors.magenta = colors.purple
colors.connected = colors.green
colors.bg1 = colors.chip
colors.bg2 = colors.chip
colors.bar = { bg = colors.bg, border = colors.transparent }
colors.popup = { bg = 0xf01a1b26, border = colors.chip }
colors.row_hover = 0x16ffffff

function colors.with_alpha(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then return color end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return colors
