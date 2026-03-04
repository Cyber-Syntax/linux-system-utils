#!/usr/bin/env bash

# Copyright (c) 2026, Cyber-Syntax Serif

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.

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
# Arch Linux (pacman) packages and AUR (paru) applications.
#
# TODO: make sure that all of the cleanup, update is securely can be useable
# `sudo pacman -Syu` is best for update
# other clenaups need research more
# paru update need special care like -diff to see changes for more secure
#
# use also `arch-audit` command to check cve for current packages etc.
# `-u` command can show only upgradeables which would be fixed one, so we can
# install those to more secure system instead of bothering non-fixed ones
# which `-c` command show all of the other CVE risk packages but there isn't
# fix for those, so we can just know about those and wait for the fix instead
# of installing those which may cause more risk to the system.

# --- Constants ---

# Pacman exit codes (simplified)
PACMAN_EXIT_OK=0

# --- Functions ---

# Print usage information
show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTION]

Arch Linux Package Management Utility

Options:
  --status          Check for available updates (default if no option provided)
  --update          Update all packages (pacman + AUR), interactive
  --update-pacman   Update only official (pacman) packages, interactive
  --update-aur      Update only AUR (paru) packages; shows pending list and
                    interactive PKGBUILD diff review before applying
  --help            Display this help message and exit

Notes:
  No flag ever uses --noconfirm; you will be prompted to review all changes.
  For AUR updates paru will ask you to review each PKGBUILD diff before
  building.  Examine them carefully before accepting.

Examples:
  $(basename "$0") --status
  $(basename "$0") --update-pacman
  $(basename "$0") --update-aur
  $(basename "$0") --update
EOF
}

# Print section headers
print_header() {
  echo "$1"
}

# Check for available package managers
check_dependencies() {
  HAS_PACMAN=0
  command -v pacman >/dev/null 2>&1 && HAS_PACMAN=1
  HAS_PARU=0
  command -v paru >/dev/null 2>&1 && HAS_PARU=1

  # Check pacman-contrib for checkupdates, install if missing
  install_pacman_contrib

}

install_pacman_contrib() {
  if [ "$HAS_PACMAN" -eq 1 ]; then
    # install pacman-contrib if not present
    if ! pacman -Qi pacman-contrib >/dev/null 2>&1; then
      echo "pacman-contrib not found. Installing..."
      sudo pacman -S --noconfirm pacman-contrib
    fi
  fi
}

# Function to check pacman updates
# Returns:
#   "0": No updates
#   <number>: Number of updates
#   "!": Timeout
#   "?": Error
#   "N/A": Pacman not available
get_pacman_update_count() {
  local pacman_output
  local pacman_exit_status
  local count

  if [ "$HAS_PACMAN" -ne 1 ]; then
    echo "N/A"
    return
  fi

  # Sync package databases and check for updates with timeout
  # The bash script checkupdates, included with the pacman-contrib package,
  # provides a safe way to check for upgrades to installed packages without running a system update,
  # and provides an option (-d) to download the pending updates to  the pacman cache
  # without synchronizing the database, thus avoiding partial upgrade issues when
  # later attempting to use pacman -S package to install packages.

  # FIXME: currently checkupdates give erorr on virt-manager: checkupdates ERROR: Cannot fetch updates
  pacman_output=$(timeout 15 bash -c "checkupdates" 2>/dev/null)
  pacman_exit_status=$?

  if [ $pacman_exit_status -eq $PACMAN_EXIT_OK ]; then
    # Count the number of update lines
    count=$(echo "$pacman_output" | grep -v "^$" | grep -c '^')
  elif [ $pacman_exit_status -eq 124 ]; then # Timeout
    count="!"
  else
    count="?"
  fi
  echo "$count"
}

# Function to check paru (AUR) updates
# Returns:
#   "0": No updates
#   <number>: Number of updates
#   "?": Error
#   "N/A": Paru not available
get_paru_update_count() {
  local paru_output
  local paru_exit_status
  local count

  if [ "$HAS_PARU" -ne 1 ]; then
    echo "N/A"
    return
  fi

  # Check for AUR updates.
  # paru -Qua exits 0 when updates are available and 1 when there are none;
  # treat any non-timeout non-zero exit with empty output as "no updates".
  paru_output=$(timeout 15 paru -Qua 2>/dev/null)
  paru_exit_status=$?

  if [ $paru_exit_status -eq 124 ]; then # Timeout
    count="!"
  elif [ -z "$paru_output" ]; then
    # Empty output regardless of exit code means no updates
    count="0"
  elif [ $paru_exit_status -eq 0 ]; then
    # Updates available — count non-blank lines
    count=$(echo "$paru_output" | grep -v "^$" | grep -c '^')
  else
    count="?"
  fi
  echo "$count"
}

# Function to update pacman packages and perform related cleanup
# NOTE: Do not clear pacman cache or orphaned packages here.
# Let paccache.timer handle cache eviction.
# Per Arch wiki, always use `pacman -Syu` (full upgrade); never partial
# upgrades (`-Sy package`).  No --noconfirm so the user can review alerts
# and .pacnew/.pacsave notices before committing.
update_pacman() {
  if [ "$HAS_PACMAN" -ne 1 ]; then
    echo "Pacman not available, skipping Arch updates."
    return 0
  fi

  print_header "Updating Arch Packages (pacman -Syu)"
  echo "Review the package list and any alerts carefully before confirming."
  echo
  if sudo pacman -Syu; then
    echo
    echo "Arch packages updated successfully."
    echo "If .pacnew/.pacsave files were created, handle them with pacdiff."
    echo
  else
    echo
    echo "Arch update encountered issues. Check the output above."
    echo
  fi
}

# Show pending AUR updates so the user knows what is about to change.
# Uses the same lightweight `paru -Qua` check as get_paru_update_count.
show_aur_pending() {
  local pending
  pending=$(paru -Qua 2>/dev/null)
  if [ -z "$pending" ]; then
    echo "No pending AUR updates."
    return 1
  fi
  echo "Pending AUR updates:"
  echo "$pending"
  echo
  return 0
}

# Function to update paru (AUR) applications.
# SECURITY NOTES:
#   - Never use --noconfirm; paru will interactively ask you to review each
#     PKGBUILD diff and confirm the build before proceeding.
#   - `-Sua` limits the update to AUR packages only (no official repo sync).
#   - Inspect every PKGBUILD diff carefully; malicious AUR packages exist.
update_paru() {
  if [ "$HAS_PARU" -ne 1 ]; then
    echo "Paru not available, skipping AUR updates."
    return 0
  fi

  print_header "Updating AUR Applications"

  # Show what will be updated before touching anything
  if ! show_aur_pending; then
    return 0
  fi

  echo "Paru will ask you to review each PKGBUILD diff before building."
  echo "Read every diff carefully and decline anything suspicious."
  echo

  # `-Sua`: AUR-only upgrade; interactive PKGBUILD review and confirmation
  if paru -Sua; then
    echo
    echo "AUR applications updated successfully."
    echo
  else
    echo
    echo "AUR update encountered issues. Check the output above."
    echo
  fi
}

# Function to update the qtile widget if qtile is available
update_qtile_widget() {
  # best-effort: tell qtile to immediately poll the widget
  if command -v qtile >/dev/null 2>&1; then
    if ! qtile cmd-obj -o widget arch-package-manager -f force_update; then
      echo "Note: Failed to update qtile widget. This is optional and does not affect the update."
    fi
  fi
}

# Function to check status of updates
check_status() {
  # ------------- Pacman Update Info -------------
  pacman_count=$(get_pacman_update_count)

  # ------------- Paru (AUR) Update Info -------------
  paru_count=$(get_paru_update_count)

  # ------------- Combined Output -------------
  # Store original values before formatting for combined status check
  original_pacman="$pacman_count"
  original_paru="$paru_count"

  # Show checkmark instead of "0" for better readability
  [ "$pacman_count" = "0" ] && pacman_count="✓ "
  [ "$paru_count" = "0" ] && paru_count="✓ "

  # Format the error indicators
  [ "$pacman_count" = "!" ] && pacman_count="TIMEOUT"         # Timeout indicator
  [ "$pacman_count" = "?" ] && pacman_count="ERROR"           # Error indicator
  [ "$paru_count" = "?" ] && paru_count="ERROR"               # Error indicator
  [ "$pacman_count" = "N/A" ] && pacman_count="Not Available" # Not available
  [ "$paru_count" = "N/A" ] && paru_count="Not Available"     # Not available

  # If both systems are up-to-date (both original values were "0"), show only a single check mark
  if [ "$original_pacman" = "0" ] && [ "$original_paru" = "0" ]; then
    echo "Up-to-date"
  else
    echo "Pacman: $pacman_count | Paru: $paru_count"
  fi
}

# Function to update all packages
update_packages() {
  update_pacman
  update_paru

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
--update-pacman)
  update_pacman
  update_qtile_widget
  ;;
--update-aur)
  update_paru
  update_qtile_widget
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
