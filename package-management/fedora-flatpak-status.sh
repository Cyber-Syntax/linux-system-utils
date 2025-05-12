#!/bin/bash
# This script checks for available Fedora (dnf) and Flatpak updates,
# and prints a summary in the format:
# Fedora: <dnf count> | Flatpak: <flatpak count>

# ------------- DNF (Fedora) Update Info -------------
# Use dnf check-update with a timeout to prevent hanging on GPG key prompts
# Exit code 100 means updates are available, 0 means no updates
# Use -y to automatically answer yes to any prompts like GPG key imports

# Create a function to run dnf with a timeout
run_dnf_with_timeout() {
  # Use timeout command to kill after 15 seconds if stuck
  timeout 15 dnf check-update --refresh -y 2>/dev/null
  return $?
}

# First try with auto-confirmation for GPG keys
dnf_output=$(run_dnf_with_timeout)
dnf_exit=$?

if [ $dnf_exit -eq 0 ]; then
  # No updates available
  fedora_count="0"
elif [ $dnf_exit -eq 100 ]; then
  # Updates available - count actual package lines (excluding headers and empty lines)
  fedora_count=$(echo "$dnf_output" | grep -v "^Last metadata" | grep -v "^$" | grep -v "^Upgrade" | wc -l | tr -d ' ')
elif [ $dnf_exit -eq 124 ]; then
  # Exit code 124 means the timeout command killed the process
  fedora_count="!"  # Use ! to indicate timeout
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
# Store original values before formatting for combined status check
original_fedora="$fedora_count"
original_flatpak="$flatpak_count"

# Show checkmark instead of "0" for better readability
[ "$fedora_count" = "0" ] && fedora_count="✅"
[ "$flatpak_count" = "0" ] && flatpak_count="✅"

# Format the error indicators
[ "$fedora_count" = "!" ] && fedora_count="⏱️" # Timeout indicator
[ "$fedora_count" = "?" ] && fedora_count="❓" # Error indicator
[ "$flatpak_count" = "?" ] && flatpak_count="❓" # Error indicator

FEDORA_ICON=$'\uf30a' # FontAwesome Fedora logo

# If both systems are up-to-date (both original values were "0"), show only a single check mark
if [ "$original_fedora" = "0" ] && [ "$original_flatpak" = "0" ]; then
  echo "✅ Up-to-date"
else
  echo "$FEDORA_ICON : $fedora_count | 📦: $flatpak_count"
fi
