#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# copy-repos-to-vm.sh
# ----------------------------------------------------------------------------
# Lightweight helper script used by the author to synchronize a handful of
# local Git repositories into a folder that is exposed to a virtual machine
# (typically via a libvirt/virt‑manager "shared folder" mounted under
# /mnt/backups/virt-manager-share).
#
# The script is intentionally simple: it uses rsync in archive mode with
# --delete in order to mirror the workspace to the VM each time it is run.
# This makes it easy to iterate on code inside the VM without maintaining a
# separate remote origin.
#
# Usage: just execute the script.  The source directories are hard-coded for
# convenience but can be overridden by exporting the `SOURCE_DIRS` array
# before running.  The destination base path is taken from
# $VIRT_SHARED_FOLDER_DIR (with a sensible default used if the variable is
# unset).
#
# Dependencies:
#  * bash
#  * rsync
#
# Example override:
#   SOURCE_DIRS=("$HOME/Projects/foo" "$HOME/Projects/bar") \
#   VIRT_SHARED_FOLDER_DIR=/mnt/backups/virt-manager-share/shared-folder \
#   ./src/automation/copy-repos-to-vm.sh
#
# ----------------------------------------------------------------------------

set -euo pipefail

# directories containing repos to sync; space-separated list is easier to loop
SOURCE_DIRS=("$HOME/Documents/my-repos/my-unicorn" \
             "$HOME/Documents/my-repos/auto-penguin-setup" \
             "$HOME/Documents/my-repos/linux-system-utils")

# destination base directory inside the VM shared folder.  only
# VIRT_SHARED_FOLDER_DIR is respected – the name makes it explicit that the
# folder is the virt‑manager shared directory.  a hard‑coded default is used
# when the variable is unset.
VIRT_SHARED_FOLDER_DIR="${VIRT_SHARED_FOLDER_DIR:-/mnt/backups/virt-manager-share/shared-folder}"
SHARED_FOLDER_DIR="$VIRT_SHARED_FOLDER_DIR"

# TODO: support a command-line argument or config file instead of relying
# solely on this single environment variable.


# perform the actual synchronization.  we add a trailing slash to the
# source so rsync copies the contents of each directory rather than the
# directory itself.  the destination path is constructed dynamically so that
# each repo ends up in its own subdirectory under the shared folder.
#
# note: if any of the source directories are missing rsync will error out and
# the script will exit immediately due to set -e.

for src in "${SOURCE_DIRS[@]}"; do
    # basename is used to preserve the directory name under the shared folder
    dest="${SHARED_FOLDER_DIR%/}/$(basename "$src")/"
    echo "Syncing $src -> $dest"
    rsync -av --delete "${src%/}/" "$dest"
done
