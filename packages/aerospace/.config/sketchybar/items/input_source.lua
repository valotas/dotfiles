local logging = require("helpers.logging")
local colors = require("colors")
local settings = require("settings")

local input_source = sbar.add("item", "input_source", {
  icon = {
    drawing = false,
  },
  label = {
    string = "🌐",
    font = {
      size = 12,
      style = "Black",
    },
  },
  position = "right",
})

local labels = {
  ["com.apple.keylayout.US"] = "en",
  ["com.apple.keylayout.Greek"] = "gr",
}

local function update_input_source()
  sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID", function(lang)
    lang = lang:gsub("^%s*(.-)%s*$", "%1")
    local label = labels[lang] or "🌐"
    logging.log("Input source: " .. lang)
    input_source:set({
      label = { string = label }
    })
  end)
end

update_input_source()

sbar.add("event", "input_source_change", "AppleSelectedInputSourcesChangedNotification")
input_source:subscribe("input_source_change", update_input_source)