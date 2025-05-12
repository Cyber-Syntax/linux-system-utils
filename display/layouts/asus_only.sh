#!/usr/bin/env sh
export DISPLAY=":0"
monitor_center="DP-4"
rate=143.97

# Properly disable screen blanking and power management with error handling
if ! xset s off; then
    echo "Warning: Failed to disable screen saver"
fi

if ! xset -dpms; then
    echo "Warning: Failed to disable DPMS (Energy Star) features"
fi

if ! xset s noblank; then
    echo "Warning: Failed to disable screen blanking"
fi

# Ensure the monitor is connected before proceeding
if xrandr --listmonitors | grep -q "$monitor_center"; then
  xrandr --output "$monitor_center" --primary --rate "$rate" --mode 2560x1440 --rotate normal
else
  echo "$monitor_center is not connected. Skipping..."
fi
