#!/bin/bash

# This bash script cleans up old backups for the superproductivity.

backup_dir="$HOME/.config/superProductivity/backups"

# Backup date format: 2025-07-03.json
# Keep 30 backups, delete the rest
keep_count=30

if [ -d "$backup_dir" ]; then
  echo "Cleaning up old backups in $backup_dir..."

  # Find all backup files, sort them by modification time, and delete the oldest ones
  find "$backup_dir" -type f -name "*.json" | sort | head -n -$keep_count | xargs -r rm

  echo "Cleanup complete. Kept the latest $keep_count backups."
else
  echo "Backup directory $backup_dir does not exist."
fi
