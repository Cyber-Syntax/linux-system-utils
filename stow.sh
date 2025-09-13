#!/bin/bash
# setup.sh - Unified setup, deploy, and init script for stowing content directories (non-dotfiles)
# Version: 1.0.0
# Description: This script manages the setup and deployment of content directories (dev and blog)
#              from a stow repository to an Obsidian vault using GNU Stow.
# Usage: ./setup.sh [--setup | --deploy | --help]
# Options:
#   --setup       Run setup: preview and copy content folders from published vault into stow repo
#   --deploy      Run deployment: preview and apply stow symlinks to published vault
#   --help        Show this help message
#
# Author: Cyber-Syntax
# License: BSD 3-Clause License

set -euo pipefail

# Variables
SOURCE_DIR="$HOME/Documents/my-repos/cyber-syntax.github.io"
DEV_DIR="$SOURCE_DIR/dev"
BLOG_DIR="$SOURCE_DIR/blog"

TARGET_DIR="$HOME/Documents/obsidian/main-vault/published"
DEV_TARGET="$TARGET_DIR/dev"
BLOG_TARGET="$TARGET_DIR/blog"

CONTENT_DIRS=(dev blog)

# Help message
show_help() {
  cat <<EOF
Usage: setup.sh [OPTION]

Options:
  --setup       Run setup: preview and copy content folders from published vault into stow repo
  --deploy      Run deployment: preview and apply stow symlinks to published vault
  --help        Show this help message
EOF
}

# Dry-copy preview function
preview_move() {
  echo "[+] Preview of folders to be copied from vault to stow repo:"
  echo "[+] Target (vault) directory: $TARGET_DIR"
  echo "[+] Source (stow repo) directory: $SOURCE_DIR"

  for dir in "${CONTENT_DIRS[@]}"; do
    SRC="$TARGET_DIR/$dir"
    DEST="$SOURCE_DIR/$dir"
    if [ -d "$SRC" ]; then
      echo "  ✓ $SRC -> $DEST"
    else
      echo "  ✗ $SRC -> $DEST (source not found)"
    fi
  done
}

# Confirm before setup
confirm_setup() {
  printf "Do you want to proceed with copying files from vault to stow repo? [y/N]: "
  read -r answer
  case "$answer" in
    [Yy]*) setup ;;
    *) echo "[!] Setup aborted by user."; exit 1 ;;
  esac
}

# Setup function: copy folders from vault to repo to prepare for stow
setup() {
  echo "[+] Copying folders from published vault to stow repo..."

  for dir in "${CONTENT_DIRS[@]}"; do
    SRC="$TARGET_DIR/$dir"
    DEST="$SOURCE_DIR/$dir"

    if [ -d "$SRC" ]; then
      echo "[+] Copying $SRC to $DEST"
      cp -r "$SRC" "$DEST"
    else
      echo "[!] Skipping $SRC (not found)"
    fi
  done
}

# Dry-run function: Show what will be symlinked
dry_run() {
  echo "[+] Running dry-run..."
  cd "$SOURCE_DIR"
  stow -n -v --dir="$SOURCE_DIR" --target="$DEV_TARGET" dev
  stow -n -v --dir="$SOURCE_DIR" --target="$BLOG_TARGET" blog
}

# Deploy function: Perform stow
deploy() {
  echo "[+] Deploying content to $TARGET_DIR..."
  cd "$SOURCE_DIR"
  stow --dir="$SOURCE_DIR" --target="$DEV_TARGET" dev
  stow --dir="$SOURCE_DIR" --target="$BLOG_TARGET" blog
  echo "[+] Deployment complete."
}

# Confirm before deploy
confirm_deploy() {
  printf "Do you want to proceed with actual deployment? [y/N]: "
  read -r answer
  case "$answer" in
    [Yy]*) deploy ;;
    *) echo "[!] Deployment aborted by user."; exit 1 ;;
  esac
}

# Main logic
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

case "$1" in
  --setup) preview_move; confirm_setup ;;
  --deploy) dry_run; confirm_deploy ;;
  --help) show_help ;;
  *) echo "[!] Unknown option: $1"; show_help; exit 1 ;;
esac
