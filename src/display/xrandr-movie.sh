#!/bin/sh
set -x # Enable verbose output for debugging

export DISPLAY=":0"

monitor_left="DP-0"
monitor_center="HDMI-0"
# monitor_right="HDMI-0"

# Check if "None-1-1" is a connected output
# if xrandr | grep -q "None-1-1 connected"; then
#   xrandr --output None-1-1 --off
# else
#   echo "None-1-1 is not connected. Skipping..."
# fi

# Define the display configurations
xrandr --output $monitor_center --primary --rate 144 --mode 2560x1440 --rotate normal \
  --output $monitor_left --off \
  --output DP-3 --off \
  --output DP-4 --off \
  --output DP-5 --off
