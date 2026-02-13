#!/bin/sh
#
# This script toggles between C (English) and Turkish locale on click
#
# Example:
# %a, %d %b %Y %H:%M       =>  Mon, 24 Jun 2024 15:30
# When clicked, it changes to: Paz, 24 Haz 2024 15:30

# Change format here. see `man date` for format controls.
FORMAT="%a, %d %b %Y %H:%M"
locale="C"

print_date() {
  LANG=$locale TZ="Europe/Istanbul" date +"${FORMAT}"
}

click() {
  if [ "$locale" = "C" ]; then
    locale="tr_TR.UTF-8"
  else
    locale="C"
  fi
  print_date
}

# Setup signal handler for USR1 to handle clicks
trap "click" USR1

while true; do
  print_date
  sleep 5 &
  wait
done