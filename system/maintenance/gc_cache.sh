#!/bin/bash
# This script moves directories in ~/.cache/appimage-run that are older than 120 day to the trash.

# Set the target directory.
CACHE_DIR="$HOME/.cache/appimage-run"

# Verify that the target directory exists.
if [ ! -d "$CACHE_DIR" ]; then
    echo "Error: Directory '$CACHE_DIR' does not exist."
    exit 1
fi

# Define the age threshold in days.
THRESHOLD=120

# Check if the trash-put command is available.
if ! command -v trash-put >/dev/null 2>&1; then
    echo "Error: 'trash-put' command not found. Please install trash-cli to use this script."
    exit 1
fi

# Find directories in CACHE_DIR (non-recursively) that have a modification time older than the threshold.
# -mindepth 1 ensures that we don't include the CACHE_DIR itself.
# -maxdepth 1 limits the search to immediate subdirectories.
# -type d finds only directories.
# -mtime +$THRESHOLD selects directories modified more than THRESHOLD days ago.
find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +$THRESHOLD | while read -r dir; do
    # Display what is being moved.
    echo "Moving directory to trash: $dir"
    # Move the directory to trash.
    trash-put "$dir"
done

