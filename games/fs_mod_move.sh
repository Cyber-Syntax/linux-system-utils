#!/bin/sh
# This script moves all Farming Simulator mods (starting with FS25_) to the game mod directory

DOWNLOADED_DIR="$HOME/Downloads"

# Change this according to your farming simulator version
VERSION="FS25"

# Change this according to your setup
MOD_DIR="/mnt/sda2/epicgames/Heroic/Prefixes/default/Farming Simulator 25/drive_c/users/steamuser/Documents/My Games/FarmingSimulator2025/mods"

# Check if mod directory exists
if [ -d "$MOD_DIR" ]; then
  echo "Mod directory $MOD_DIR exists."

  # Check if there are any .zip files starting with FS25_ in the downloaded directory
  if [ -n "$(find "$DOWNLOADED_DIR" -maxdepth 1 -type f -name "FS25_*.zip")" ]; then
    echo "Moving FS25_*.zip files from $DOWNLOADED_DIR to $MOD_DIR"

    # Move all FS25_*.zip files from the downloaded directory to the mod directory
    mv "$DOWNLOADED_DIR"/"$VERSION"_*.zip "$MOD_DIR"

    echo "Files moved successfully."
  else
    echo "No "$VERSION"_*.zip files found in $DOWNLOADED_DIR."
  fi
else
  echo "Mod directory $MOD_DIR does not exist."
fi
