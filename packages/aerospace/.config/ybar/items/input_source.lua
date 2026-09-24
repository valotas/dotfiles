local colors = require("colors")

local input_source = sbar.add("item", "input_source", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "en",
    color = colors.purple,
    padding_left = 4,
    padding_right = 8,
  },
})

sbar.add("item", "tokyonight.pad_lang", { position = "right", width = 10 })

local labels = {
  ["com.apple.keylayout.US"] = "en",
  ["com.apple.keylayout.Greek"] = "gr",
}

local function update_input_source()
  sbar.exec(
    "defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID",
    function(lang)
      lang = lang:gsub("^%s*(.-)%s*$", "%1")
      input_source:set({
        label = { string = labels[lang] or "??", color = colors.purple }
      })
    end
  )
end

update_input_source()

sbar.add("event", "input_source_change", "AppleSelectedInputSourcesChangedNotification")
input_source:subscribe("input_source_change", update_input_source)
