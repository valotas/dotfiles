-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.env("XCURSOR_SIZE", "20")

-- Laptop panel and any display without its own rule.
hl.monitor({ output = "", mode = "3200x1800@60", position = "auto", scale = 1.6 })

-- Dell U3821DW. Native 3840x1600. HD 620 drops this to 2560x1440 when the
-- laptop panel is enabled at the same time. reapply-external-native.sh stays
-- running and restores 3840x1600 once clamshell mode has turned the panel off.
hl.monitor({ output = "DP-1", mode = "3840x1600@59.99", position = "auto", scale = 1 })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
