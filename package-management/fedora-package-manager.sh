#!/usr/bin/env bash
# Copyright (c) 2025, Cyber-Syntax Serif
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This script provides both status checking and update functionality for
# Fedora (DNF) packages and Flatpak applications.

# --- Constants ---

# DNF exit codes
DNF_EXIT_TIMEOUT=124

# --- Functions ---

# Print usage information
show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTION]

Fedora Package Management Utility

Options:
  --status       Check for available updates (default if no option provided)
  --update       Update all packages and perform cleanup
  --help         Display this help message and exit

Examples:
  $(basename "$0") --status
  $(basename "$0") --update
EOF
}

# Print section headers
print_header() {
  echo "$1"
}

# Check for available package managers
check_dependencies() {
  HAS_DNF=0
  command -v dnf >/dev/null 2>&1 && HAS_DNF=1
  HAS_FLATPAK=0
  command -v flatpak >/dev/null 2>&1 && HAS_FLATPAK=1
}

# Function to check DNF (Fedora) updates
# Returns:
#   "0": No updates
#   <number>: Number of updates
#   "!": Timeout
#   "?": Error
#   "N/A": DNF not available
get_dnf_update_count() {
  local dnf_output
  local dnf_exit_status
  local count

  if [ "$HAS_DNF" -ne 1 ]; then
    echo "N/A"
    return
  fi

  # Use timeout command to kill after 15 seconds if stuck
  dnf_output=$(timeout 15 dnf updateinfo -q list 2>/dev/null)
  dnf_exit_status=$?

  if [ $dnf_exit_status -eq 0 ]; then
    count=$(echo "$dnf_output" | wc -l)
    if echo "$dnf_output" | grep -q "No updates needed"; then
      count=0
    fi
  elif [ $dnf_exit_status -eq $DNF_EXIT_TIMEOUT ]; then
    count="!" # Timeout indicator
  else
    count="?" # Any other exit code indicates an error
  fi
  echo "$count"
}

# Function to check Flatpak updates
# Returns:
#   "0": No updates
#   <number>: Number of updates
#   "?": Error
#   "N/A": Flatpak not available
get_flatpak_update_count() {
  local flatpak_output
  local flatpak_exit_status
  local count

  if [ "$HAS_FLATPAK" -ne 1 ]; then
    echo "N/A"
    return
  fi

  flatpak_output=$(timeout 15 flatpak update 2>/dev/null)
  flatpak_exit_status=$?

  if [ $flatpak_exit_status -eq 0 ]; then
    count=$(echo "$flatpak_output" | tail -n +5 | grep -Ecv "^$|^Proceed|^Nothing")
  else
    count="?"
  fi
  echo "$count"
}

# Function to update DNF packages and perform related cleanup
update_dnf() {
  if [ "$HAS_DNF" -ne 1 ]; then
    echo "DNF not available, skipping Fedora updates."
    return 0
  fi

  # Update Fedora packages
  print_header "Updating Fedora Packages"
  if sudo dnf update -y --refresh --allowerasing; then
    echo "Fedora packages updated successfully."
    echo
  else
    echo "Fedora update encountered issues. Check the output above."
    echo
  fi

  # Clean up DNF cache (optional but good practice)
  print_header "Cleaning DNF Cache"
  if sudo dnf clean packages --quiet; then
    echo "DNF cache cleaned successfully."
    echo
  fi

  # Remove orphaned packages (optional but good practice)
  print_header "Removing Orphaned Packages"
  if sudo dnf autoremove -y; then
    echo "Orphaned packages removed successfully."
    echo
  fi
}

# Function to update Flatpak applications and perform related cleanup
update_flatpak() {
  if [ "$HAS_FLATPAK" -ne 1 ]; then
    echo "Flatpak not available, skipping Flatpak updates."
    return 0
  fi

  # Update Flatpak applications
  print_header "Updating Flatpak Applications"
  if flatpak update -y; then
    echo "Flatpak applications updated successfully."
    echo
  else
    echo "Flatpak update encountered issues. Check the output above."
    echo
  fi

  # Remove old Flatpak runtimes (optional but good practice)
  print_header "Cleaning Flatpak Runtimes"
  if flatpak uninstall --unused -y; then
    echo "Unused Flatpak runtimes removed successfully."
    echo
  fi
}

# Function to update the qtile widget if qtile is available
update_qtile_widget() {
  # best-effort: tell qtile to immediately poll the widget
  if command -v qtile >/dev/null 2>&1; then
    if ! qtile cmd-obj -o widget fedora-package-manager -f force_update; then
      echo "Note: Failed to update qtile widget. This is optional and does not affect the update."
    fi
  fi
}

# Function to check status of updates
check_status() {
  # ------------- DNF (Fedora) Update Info -------------
  fedora_count=$(get_dnf_update_count)

  # ------------- Flatpak Update Info -------------
  flatpak_count=$(get_flatpak_update_count)

  # ------------- Combined Output -------------
  # Store original values before formatting for combined status check
  original_fedora="$fedora_count"
  original_flatpak="$flatpak_count"

  # Show checkmark instead of "0" for better readability
  [ "$fedora_count" = "0" ] && fedora_count="✓ "
  [ "$flatpak_count" = "0" ] && flatpak_count="✓ "

  # Format the error indicators
  [ "$fedora_count" = "!" ] && fedora_count="TIMEOUT"           # Timeout indicator
  [ "$fedora_count" = "?" ] && fedora_count="ERROR"             # Error indicator
  [ "$flatpak_count" = "?" ] && flatpak_count="ERROR"           # Error indicator
  [ "$fedora_count" = "N/A" ] && fedora_count="Not Available"   # Not available
  [ "$flatpak_count" = "N/A" ] && flatpak_count="Not Available" # Not available

  if { [ "$original_fedora" = "0" ] || [ "$original_fedora" = "N/A" ]; } && { [ "$original_flatpak" = "0" ] || [ "$original_flatpak" = "N/A" ]; }; then
    echo ""
  else
    echo "Fedora: $original_fedora | Flatpak: $original_flatpak"
  fi
}

# Function to update all packages
update_packages() {
  update_dnf
  update_flatpak

  # Final message
  print_header "Update Process Completed"

  # Update qtile widget if applicable
  update_qtile_widget
}

# --- Main Script ---

# Handle help first
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  show_help
  exit 0
fi

# Check dependencies
check_dependencies

# Parse command line options
case "$1" in
  --status)
    check_status
    ;;
  --update)
    update_packages
    ;;
  --help | -h | "")
    show_help
    ;;
  *)
    echo "Invalid option: $1"
    echo ""
    show_help
    exit 1
    ;;
esac

exit 0
