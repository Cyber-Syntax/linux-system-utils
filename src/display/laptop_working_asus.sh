#!/bin/bash

# Define the desired outputs and modes
LAPTOP_OUTPUT="eDP-1"
EXTERNAL_OUTPUT="HDMI-1"
LAPTOP_MODE="1920x1200"
EXTERNAL_MODE="2560x1440"
EXTERNAL_RATE="144"
LAPTOP_RATE="60"

# Check if HDMI-1 is connected
if xrandr | grep -q "$EXTERNAL_OUTPUT connected"; then
  # Set laptop as primary, left
  xrandr --output $LAPTOP_OUTPUT --mode $LAPTOP_MODE --pos 0x0 --primary --rate $LAPTOP_RATE
  # Set HDMI-1 as right, 144Hz
  xrandr --output $EXTERNAL_OUTPUT --mode $EXTERNAL_MODE --rate $EXTERNAL_RATE --pos 1920x0 --right-of $LAPTOP_OUTPUT
  echo "Monitors configured: $LAPTOP_OUTPUT (left, primary), $EXTERNAL_OUTPUT (right, 144Hz)"
else
  # Only laptop is connected
  xrandr --output $LAPTOP_OUTPUT --mode $LAPTOP_MODE --pos 0x0 --primary
  xrandr --output $EXTERNAL_OUTPUT --off
  echo "Only $LAPTOP_OUTPUT is active."
fi
