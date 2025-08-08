--local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local icons = require("icons")

sbar.add("item", "front_app_start", {
  display = "active",
  icon = {
    string = icons.divider,
    font = {
      style = settings.font.style_map["Black"],
    }
  },
})

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = {
    font = settings.app_font,
    padding_right = settings.paddings,
    padding_left = settings.paddings
  },
  label = {
    font = {
      style = settings.font.style_map["Black"],
    },
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  --logging.log("front_app_switched: " .. env.INFO .. " " .. icon)
  front_app:set({ icon = { string = app_icons.app_icon(env.INFO) }, label = { string = env.INFO } })
end)
