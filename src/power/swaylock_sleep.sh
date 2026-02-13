#!/bin/bash
# Hyprland Idle Management Script

# Kill previous instances
pkill -9 swayidle
while pgrep -u $UID -x swayidle >/dev/null; do sleep 0.5; done

# Lock screen configuration
LOCK_CMD='swaylock -f --screenshots --effect-blur 7x5'
SUSPEND_CMD='systemctl suspend'

# Start swayidle with proper Hyprland integration
swayidle -w \
  timeout 300 "$LOCK_CMD" \
  timeout 600 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on' \
  before-sleep "$LOCK_CMD" \
  lock "$LOCK_CMD" &
