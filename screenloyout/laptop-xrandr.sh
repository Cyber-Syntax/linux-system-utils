
#!/bin/sh
set -x # Enable verbose output for debugging

# systemctl --user import-environment DISPLAY XAUTHORITY
#
# if command -v dbus-update-activation-environment >/dev/null 2>&1; then
#     dbus-update-activation-environment DISPLAY XAUTHORITY
# fi
#
# Check if the current DISPLAY is ":0" or not
if [[ $DISPLAY == ":0" ]]; then
    export DISPLAY=:0
else
    export DISPLAY=:1
fi

laptop_monitor="eDP-1"
tv_monitor="HDMI-1"

xrandr --output $laptop_monitor --primary --rate 60 --mode 1920x1200 --rotate normal \
       --output $tv_monitor --rate 60 --mode 1920x1080 --rotate normal --right-of $laptop_monitor
