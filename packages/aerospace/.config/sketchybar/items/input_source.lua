--local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local icons = require("icons")
local logging = require("helpers.logging")
local json = require("helpers.json")

local input_source = sbar.add("item", "input_source", {
  icon = {
    string = "🌐",
    font = {
      size = 12
    }
  },
  position = "right",
})

local labels = {
  ["com.apple.keylayout.US"] = "🇺🇸",
  ["com.apple.keylayout.Greek"] = "🇬🇷",
}

local function update_input_source()
  sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID", function(lang)
    lang = lang:gsub("^%s*(.-)%s*$", "%1")
    local label = labels[lang] or "🌐"
    logging.log("Input source: " .. lang)
    input_source:set({
      icon = { string = label }
    })
  end)
end

update_input_source()

input_source:subscribe("input_source_change", update_input_source)