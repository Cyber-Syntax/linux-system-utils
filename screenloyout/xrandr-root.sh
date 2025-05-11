#!/bin/sh
set -x # Enable verbose output for debugging

#/etc/X11/xinit/xinitrc.d/50-systemd-user.sh
systemctl --user import-environment DISPLAY XAUTHORITY

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment DISPLAY XAUTHORITY
fi

export DISPLAY=$(w -h $USER | awk '$2 ~ /:[0-9.]*/{print $2}')

monitor_left="DP-0"
monitor_center="DP-2"
monitor_right="HDMI-0"

# Define the display configurations
xrandr --output $monitor_center --primary --rate 143.97 --mode 2560x1440 --rotate normal \
       --output $monitor_right --rate 59.79 --mode 1366x768 --rotate normal --right-of $monitor_center \
       --output $monitor_left --mode 1920x1080 --pos 0x0 --rate 60 --rotate normal --left-of $monitor_center \
       --output DP-3 --off \
       --output DP-4 --off \
       --output DP-5 --off \
