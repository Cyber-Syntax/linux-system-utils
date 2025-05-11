#!/bin/sh
set -x # Enable verbose output for debugging

export DISPLAY=":0"

monitor_left="DP-0"
monitor_center="DP-2"
monitor_right="HDMI-0"

# Check if "None-1-1" is a connected output
if xrandr | grep -q "None-1-1 connected"; then
	xrandr --output None-1-1 --off
else
	echo "None-1-1 is not connected. Skipping..."
fi

# Define the display configurations
xrandr --output $monitor_center --primary --rate 143.97 --mode 2560x1440 --rotate normal \
       --output $monitor_right --rate 59.79 --mode 1366x768 --rotate normal --right-of $monitor_center \
       --output $monitor_left --off \
       --output DP-3 --off \
       --output DP-4 --off \
       --output DP-5 --off \
