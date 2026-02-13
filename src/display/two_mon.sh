#!/usr/bin/env sh
export DISPLAY=":0"
monitor_right="DP-2"
monitor_left="DP-0"
rate=143.97
rate_left=144

# Ensure the monitors connected before proceeding
#TODO: better check for both monitors
# if xrandr --listmonitors | grep -q "$monitor_right"; then
xrandr --output "$monitor_right" --primary --rate "$rate" --mode 2560x1440 --rotate normal \
  --output "$monitor_left" --rate "$rate_left" --mode 1920x1080 --rotate normal --left-of "$monitor_right"
# else
#   echo "$monitor_right is not connected. Skipping..."
# fi
