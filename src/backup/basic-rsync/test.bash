#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Source directory to backup
SOURCE_DIR="${HOME}/Documents"
echo "Backing up from: ${SOURCE_DIR}"

# Directory where backups are stored
BACKUP_DIR="/mnt/backups/rsync/"
echo "Backup directory: ${BACKUP_DIR}"

# Timestamp for the current backup folder
DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"

# Full path for this backup
BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"

# Symlink to the latest backup
LATEST_LINK="${BACKUP_DIR}/latest"

# Ensure backup directory exists
mkdir -p "${BACKUP_DIR}"

# Run rsync with incremental backup using --link-dest to hardlink unchanged files
rsync -av --delete \
  --exclude-from "exclude_files.txt" \
  --link-dest="${LATEST_LINK}" \
  "${SOURCE_DIR}/" \
  "${BACKUP_PATH}"

# Update the 'latest' symlink to point to the new backup
rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
