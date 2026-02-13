#!/bin/bash
# Script to remove build artifacts, cache directories, and .egg-info directories from a Python project

# Define the directories and file patterns to remove
dirs=("build" "dist" "__pycache__" "*.egg-info")

# Loop over each item and remove if it exists
for dir in "${dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo "Removing directory: $dir"
    rm -rf "$dir"
  elif [ -f "$dir" ]; then
    echo "Removing file: $dir"
    rm -f "$dir"
  fi
done

# Also, remove __pycache__ directories recursively across the project
find . -type d -name '__pycache__' -exec rm -rf {} +

# Remove all .egg-info directories (no exclusions)
find . -type d -name '*.egg-info' -exec rm -rf {} +

echo "All build artifacts, caches, and .egg-info directories cleared successfully."
