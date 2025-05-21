#!/bin/bash
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

# Icons and styling
FEDORA_ICON=$'\uf30a' # FontAwesome Fedora logo
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
INVERSE='\033[7m'
NC='\033[0m' # No Color

# DNF exit codes
DNF_EXIT_OK=0
DNF_EXIT_UPDATES_AVAILABLE=100
DNF_EXIT_TIMEOUT=124

# --- Functions ---

# Print usage information
show_help() {
    cat << EOF
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
    printf "${BOLD}${INVERSE}$1${NC}\n\n"
}

# Function to check DNF (Fedora) updates
# Returns:
#   "0": No updates
#   <number>: Number of updates
#   "!": Timeout
#   "?": Error
get_dnf_update_count() {
  local dnf_output
  local dnf_exit_status
  local count

  # Use timeout command to kill after 15 seconds if stuck
  # -y to automatically answer yes to any prompts like GPG key imports
  dnf_output=$(timeout 15 dnf check-update --refresh -y 2>/dev/null)
  dnf_exit_status=$?

  if [ $dnf_exit_status -eq $DNF_EXIT_OK ]; then
    count="0"
  elif [ $dnf_exit_status -eq $DNF_EXIT_UPDATES_AVAILABLE ]; then
    # Count actual package lines (excluding headers and empty lines)
    count=$(echo "$dnf_output" | grep -v "^Last metadata" | grep -v "^$" | grep -v "^Upgrade" | wc -l | tr -d ' ')
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
get_flatpak_update_count() {
  local flatpak_output
  local flatpak_exit_status
  local count

  # First try with remote-ls --updates which is more reliable
  flatpak_output=$(flatpak remote-ls --updates 2>/dev/null)
  flatpak_exit_status=$?

  if [ $flatpak_exit_status -eq 0 ]; then
    if [ -z "$flatpak_output" ]; then
      count="0"
    else
      # Count lines in the output for available updates
      count=$(echo "$flatpak_output" | grep -v "^$" | wc -l | tr -d ' ')
    fi
  else
    # Fallback to the original method if remote-ls fails
    flatpak_output=$(flatpak update --no-deploy 2>/dev/null || echo "Error")

    if [ "$flatpak_output" = "Error" ]; then
      count="?"
    elif echo "$flatpak_output" | grep -q "Nothing to do."; then
      count="0"
    else
      # Count update lines with a more flexible pattern
      count=$(echo "$flatpak_output" | grep -E '^\s*[0-9]+\.\s+' | wc -l | tr -d ' ')
      # If count is 0 but "Nothing to do" is not found, it's likely an error or unexpected output
      if [ "$count" = "0" ] && ! echo "$flatpak_output" | grep -q "Nothing to do."; then
        count="?"
      fi
    fi
  fi
  echo "$count"
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
  [ "$fedora_count" = "0" ] && fedora_count="✅"
  [ "$flatpak_count" = "0" ] && flatpak_count="✅"

  # Format the error indicators
  [ "$fedora_count" = "!" ] && fedora_count="⏱️" # Timeout indicator
  [ "$fedora_count" = "?" ] && fedora_count="❓" # Error indicator
  [ "$flatpak_count" = "?" ] && flatpak_count="❓" # Error indicator

  # If both systems are up-to-date (both original values were "0"), show only a single check mark
  if [ "$original_fedora" = "0" ] && [ "$original_flatpak" = "0" ]; then
    echo "✅ Up-to-date"
  else
    echo "$FEDORA_ICON : $fedora_count | 📦: $flatpak_count"
  fi
}

# Function to update all packages
update_packages() {
  # Update Fedora packages
  print_header "Updating Fedora Packages"
  if sudo dnf update -y --refresh --allowerasing; then
      printf "\n${GREEN}${BOLD}Fedora packages updated successfully.${NC}\n\n"
  else
      printf "\n${YELLOW}${BOLD}Fedora update encountered issues. Check the output above.${NC}\n\n"
  fi

  # Update Flatpak applications
  print_header "Updating Flatpak Applications"
  if flatpak update -y; then
      printf "\n${GREEN}${BOLD}Flatpak applications updated successfully.${NC}\n\n"
  else
      printf "\n${YELLOW}${BOLD}Flatpak update encountered issues. Check the output above.${NC}\n\n"
  fi

  # Clean up DNF cache (optional but good practice)
  print_header "Cleaning DNF Cache"
  if sudo dnf clean packages --quiet; then
      printf "${CYAN}DNF cache cleaned successfully.${NC}\n\n"
  fi

  # Remove orphaned packages (optional but good practice)
  print_header "Removing Orphaned Packages"
  if sudo dnf autoremove -y; then
      printf "${CYAN}Orphaned packages removed successfully.${NC}\n\n"
  fi

  # Remove old Flatpak runtimes (optional but good practice)
  print_header "Cleaning Flatpak Runtimes"
  if flatpak uninstall --unused -y; then
      printf "${CYAN}Unused Flatpak runtimes removed successfully.${NC}\n\n"
  fi

  # Final message
  print_header "Update Process Completed"
}

# --- Main Script ---

# Parse command line options
case "$1" in
  --status|"")
    # Default action if no arguments provided
    check_status
    ;;
  --update)
    update_packages
    ;;
  --help|-h)
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