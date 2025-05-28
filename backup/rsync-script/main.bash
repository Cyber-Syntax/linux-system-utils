#!/bin/bash

# A script to perform incremental backups using rsync

set -o errexit
set -o nounset
set -o pipefail

readonly SOURCE_DIR="${HOME}/Documents"
readonly BACKUP_DIR="/media/backups/rsync"
readonly DATETIME="$(date '+%d-%m-%Y_%H:%M')"
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

mkdir -p "${BACKUP_DIR}"

rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"

rsync -av --delete \
  "${SOURCE_DIR}/" \
  --link-dest "${LATEST_LINK}" \
  --exclude-from "exclude_files.txt" \
  --log-file "${BACKUP_PATH}.log" \
  "${BACKUP_PATH}"

