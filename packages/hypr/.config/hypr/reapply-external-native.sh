#!/bin/bash

# The XPS 13 9360 (HD Graphics 620) rejects 3840x1600@60 on DP-1 while the
# 3200x1800 internal panel is also enabled, and Hyprland will not retry that
# same mode after it falls back to 2560x1440. Clamshell mode reloads the
# config when the lid closes, which is after the old one-shot had exited,
# so the Dell stayed at the soft fallback. Stay up and reapply once the
# internal panel is off. Stepping through 30 Hz forces a new modeset.

set -u

lock="${XDG_RUNTIME_DIR:-/tmp}/reapply-external-native.lock"
exec 9>"$lock"
flock -n 9 || exit 0

apply_native() {
  local json width height rate internal

  json=$(hyprctl monitors all -j 2>/dev/null) || return 0
  read -r width height rate < <(jq -r '.[] | select(.name == "DP-1" and .disabled != true) | "\(.width) \(.height) \(.refreshRate)"' <<<"$json")
  [[ -z ${width:-} ]] && return 0

  internal=$(jq -r '.[] | select(.name == "eDP-1" and .disabled != true) | .name' <<<"$json")
  [[ -n $internal ]] && return 0

  if [[ $width == 3840 && $height == 1600 ]]; then
    awk -v rate="$rate" 'BEGIN { exit !(rate + 0 >= 50) }' && return 0
  fi

  hyprctl eval 'hl.monitor({ output = "DP-1", mode = "3840x1600@30.00", position = "auto", scale = 1 })' >/dev/null
  hyprctl eval 'hl.monitor({ output = "DP-1", mode = "3840x1600@59.99", position = "auto", scale = 1 })' >/dev/null
}

signature=${HYPRLAND_INSTANCE_SIGNATURE:-}
socket="${XDG_RUNTIME_DIR}/hypr/${signature}/.socket2.sock"
[[ -S ${socket} ]] || exit 0

apply_lock="${XDG_RUNTIME_DIR}/reapply-external-native.apply"
apply_locked() {
  (
    flock -w 5 8 || exit 0
    apply_native
  ) 8>"$apply_lock"
}

apply_locked

(
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 2
    apply_locked
  done
) &

socat -u "UNIX-CONNECT:${socket}" - | while IFS= read -r line; do
  case $line in
    configreloaded*|monitoradded*|monitorremoved*|lid*)
      sleep 0.5
      apply_locked
      ;;
  esac
done
