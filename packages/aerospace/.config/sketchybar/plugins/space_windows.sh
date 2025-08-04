#!/usr/bin/env bash
 
echo AEROSPACE_PREV_WORKSPACE: $AEROSPACE_PREV_WORKSPACE, \
 AEROSPACE_FOCUSED_WORKSPACE: $AEROSPACE_FOCUSED_WORKSPACE \
 SELECTED: $SELECTED \
 BG2: $BG2 \
 INFO: $INFO \
 SENDER: $SENDER \
 NAME: $NAME \
  >> ~/tmp/sketchybar.logs

source "$CONFIG_DIR/colors.sh"

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKESPACE=$(aerospace list-workspaces --monitor focused --empty)

reload_workspace_icon() {
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  echo reload_workspace_icon "$@, pps, $icon_strip" >> ~/tmp/sketchybar.logs
  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

aerospace_workspace_change() {
  from_space="$1"
  to_space="$2"
  echo "`date -Ins`: $from_space -> $to_space" >> /tmp/sketchybar.logs

  if [ "$from_space" -ne "$to_space" ]; then
    reload_workspace_icon "$from_space"

    sketchybar --set space.$from_space icon.highlight=false \
                         label.highlight=false \
                         background.border_color=$BACKGROUND_2
  fi

  reload_workspace_icon "$to_space"

  sketchybar --set space.$to_space icon.highlight=true \
                         label.highlight=true \
                         background.border_color=$GREY

}

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  AEROSPACE_FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
  aerospace_workspace_change "$AEROSPACE_PREV_WORKSPACE" "$AEROSPACE_FOCUSED_WORKSPACE"

  for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
    sketchybar --set space.$i display=$AEROSPACE_FOCUSED_MONITOR
  done

  for i in $AEROSPACE_EMPTY_WORKESPACE; do
    sketchybar --set space.$i display=0
  done

  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR

fi
