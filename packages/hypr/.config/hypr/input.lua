-- Global input settings
hl.config({
  input = {
    -- Leave the stock compose option off. Both Shift keys toggle Caps Lock
    -- in /etc/keyd/default.conf, below fcitx, so a lone Shift stays Shift.
    -- Left Alt + Left Shift switches English and Greek (see
    -- ~/.config/omarchy/keyboard-layouts).
    kb_options = "grp:lalt_lshift_toggle",
    touchpad = {
      natural_scroll = true,
    },
  },
})
