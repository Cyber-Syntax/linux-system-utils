#!/bin/bash

# Lock screen if argument --lock is passed
if [[ $1 == "--lock" ]]; then
    swaylock --daemonize --screenshots
    exit 0
fi

# Disable screensaver (if needed)
xset s off

# Kill any existing swayidle processes before starting a new one
killall -9 swayidle

# Wait until previous processes have been shut down
while pgrep -u $UID -x swayidle >/dev/null; do
    sleep 1
done

# Start swayidle with the following configuration:
# - Lock the screen after 5 minutes (300 seconds), using the screenshot feature
# - Turn off the screen after 10 minutes (600 seconds)
# - Turn on the screen when resumed
# - Suspend the system after 20 minutes (1200 seconds)
# - Lock the screen before sleep, using the screenshot feature

swayidle -w \
    timeout 300 'swaylock -f --screenshots --effect-blur 7x5' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on' \
    before-sleep 'swaylock -f --screenshots --effect-blur 7x5' &
