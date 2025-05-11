#!/bin/bash
# This script checks for available Fedora (dnf) and Flatpak updates,
# and prints a summary in the format:
# Fedora: <dnf count> | Flatpak: <flatpak count>

# ------------- DNF (Fedora) Update Info -------------
# Use dnf check-update which is the proper way to check for available updates
# Exit code 100 means updates are available, 0 means no updates
dnf_output=$(dnf check-update --refresh 2>/dev/null)
dnf_exit=$?

if [ $dnf_exit -eq 0 ]; then
  # No updates available
  fedora_count="0"
elif [ $dnf_exit -eq 100 ]; then
  # Updates available - count actual package lines (excluding headers and empty lines)
  fedora_count=$(echo "$dnf_output" | grep -v "^Last metadata" | grep -v "^$" | grep -v "^Upgrade" | wc -l | tr -d ' ')
else
  # Any other exit code indicates an error
  fedora_count="?"
fi

# ------------- Flatpak Update Info -------------
# First try with remote-ls --updates which is more reliable
flatpak_output=$(flatpak remote-ls --updates 2>/dev/null)
flatpak_exit=$?

if [ $flatpak_exit -eq 0 ]; then
  if [ -z "$flatpak_output" ]; then
    flatpak_count="0"
  else
    # Count lines in the output for available updates
    flatpak_count=$(echo "$flatpak_output" | grep -v "^$" | wc -l | tr -d ' ')
  fi
else
  # Fallback to the original method if remote-ls fails
  flatpak_output=$(flatpak update --no-deploy 2>/dev/null || echo "Error")

  if [ "$flatpak_output" = "Error" ]; then
    flatpak_count="?"
  elif echo "$flatpak_output" | grep -q "Nothing to do."; then
    flatpak_count="0"
  else
    # Count update lines with a more flexible pattern
    flatpak_count=$(echo "$flatpak_output" | grep -E '^\s*[0-9]+\.\s+' | wc -l | tr -d ' ')
    if [ "$flatpak_count" = "0" ] && ! echo "$flatpak_output" | grep -q "Nothing to do."; then
      flatpak_count="?"
    fi
  fi
fi

# ------------- Combined Output -------------
# Show checkmark instead of "0" for better readability
[ "$fedora_count" = "0" ] && fedora_count="✅"
[ "$flatpak_count" = "0" ] && flatpak_count="✅"

FEDORA_ICON=$'\uf30a' # FontAwesome Fedora logo

echo "$FEDORA_ICON : $fedora_count | 📦: $flatpak_count"
