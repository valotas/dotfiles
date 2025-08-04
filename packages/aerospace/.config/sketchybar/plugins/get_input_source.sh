#!/bin/sh

# hangul and english item

# Read the plist data
plist_data=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources)
current_input_source=$(echo "$plist_data" | plutil -convert xml1 -o - - | grep -A1 'KeyboardLayout Name' | tail -n1 | cut -d '>' -f2 | cut -d '<' -f1)

echo $current_input_source >> ~/tmp/sketchbar.log

if [ "$current_input_source" = "Greek" ]; then
    sketchybar --set input_source icon="λ"
else
    sketchybar --set input_source icon="EN"
fi
