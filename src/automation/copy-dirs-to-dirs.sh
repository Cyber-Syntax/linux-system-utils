#!/usr/bin/env bash

# copy-dirs-to-dirs.sh
# ---------------------
# Simple helper for moving directories from a master 'MAIN' location
# into corresponding paths in the current environment. Intended to speed
# up distro hops or configuration migrations by automating repetitive
# rsync commands.
#
# Features:
#   * preconfigured source/destination pairs (syncthing, browser, docs,
#     zed config, keyrings, dotfiles, FreeTube)
#   * global dry-run mode (-n/--dry-run) which prints paths without running
#     rsync
#   * command‑line selection of individual items or 'all'
#
# Usage examples:
#   # show what would be copied for every item
#   ./copy-dirs-to-dirs.sh --dry-run
#
#   # actually sync just the syncthing config
#   ./copy-dirs-to-dirs.sh syncthing
#
#   # dry-run a single target
#   ./copy-dirs-to-dirs.sh -n freetube
#
# Configuration resides in the variables near the top of this file; add or
# modify source/destination pairs as required.  The script is intentionally
# lightweight and uses only standard POSIX tools.
#
# (C) Cyber-Syntax

# abort on error, undefined variables, and pipe failures
set -euo pipefail

# global options
DRY_RUN=false

# directory containing the master copy of files (source for all operations)
MAIN=/mnt/nvme/developer

# destination paths in the current environment
#TODO: make sure these are backed up with borg or somethin
#TODO2: move them to ~/dotfiles if they're not private or too large

#TODO: clear dirs to avoid DRY principal violations, maybe we can make them one dir
# and use front dir while copying
SYNCTHING_DIR="$HOME/.config/syncthing"
BROWSER_DIR="$HOME/.zen/"
DOCUMENTS_DIR="$HOME/Documents"
ZED_DIR="$HOME/.config/zed/"
KEYRINGS_DIR="$HOME/.local/share/keyrings/"
DOTFILES_DIR="$HOME/dotfiles/"
FreeTube_DIR="$HOME/.config/FreeTube/"
FONTS_DIR="$HOME/.local/share/fonts/"
PICTURES_DIR="$HOME/Pictures/"
PHOTOS_DIR="$HOME/Photos/"
VIDEOS_DIR="$HOME/Videos/"
ZOXIDEDB_DIR="$HOME/.local/share/zoxide/db.zo"
EASY_EFFECT_DIR="$HOME/.config/easyeffects/"

# relative paths under MAIN used as sources
SYNCTHING_SRC=".config/syncthing/"
BROWSER_SRC=".zen/"
DOCUMENTS_SRC="Documents/"
ZED_SRC=".var/app/dev.zed.Zed/config/"
KEYRINGS_SRC=".local/share/keyrings/"
DOTFILES_SRC="dotfiles/"
FreeTube_SRC=".config/FreeTube/"
FONTS_SRC=".local/share/fonts/"
PICTURES_SRC="Pictures/"
PHOTOS_SRC="Photos/"
VIDEOS_SRC="Videos/"
ZOXIDEDB_SRC=".local/share/zoxide/db.zo"
EASY_EFFECT_SRC=".config/easyeffects/"

# generic rsync wrapper
sync_with_rsync() {
  local src="$1"
  local dst="$2"

  if [[ "$DRY_RUN" == true ]]; then
    # don't execute rsync at all; just print what would happen.
    echo "[copy-dirs-to-dirs] dry run: $src -> $dst"
    return
  fi

  # normal execution shows rsync progress
  local opts=(-avxHAX --progress)
  echo "[copy-dirs-to-dirs] rsync ${opts[*]} $src -> $dst"
  rsync "${opts[@]}" "$src" "$dst"
}

# copy an item from MAIN using a relative path
copy_from_main() {
  local rel="$1"
  local dst="$2"

  sync_with_rsync "${MAIN%/}/$rel" "$dst"
}

# sync every configured directory from MAIN to local dest
sync_all() {
  copy_from_main "$SYNCTHING_SRC" "$SYNCTHING_DIR"
  copy_from_main "$BROWSER_SRC" "$BROWSER_DIR"
  copy_from_main "$DOCUMENTS_SRC" "$DOCUMENTS_DIR"
  copy_from_main "$ZED_SRC" "$ZED_DIR"
  copy_from_main "$KEYRINGS_SRC" "$KEYRINGS_DIR"
  copy_from_main "$DOTFILES_SRC" "$DOTFILES_DIR"
  copy_from_main "$FreeTube_SRC" "$FreeTube_DIR"
  copy_from_main "$FONTS_SRC" "$FONTS_DIR"
  copy_from_main "$PICTURES_SRC" "$PICTURES_DIR"
  copy_from_main "$PHOTOS_SRC" "$PHOTOS_DIR"
  copy_from_main "$VIDEOS_SRC" "$VIDEOS_DIR"
  copy_from_main "$ZOXIDEDB_SRC" "$ZOXIDEDB_DIR"
  copy_from_main "$EASY_EFFECT_SRC" "$EASY_EFFECT_DIR"
} 
# display usage message
usage() {
  cat <<'EOF'
Usage: $(basename "$0") [-n|--dry-run] [all|syncthing|browser|
    documents|zed|keyrings|dotfiles|freetube|fonts|pictures|photos|
    videos|zoxidedb|easyeffects]

Without arguments or with "all" the script copies every configured
    directory.
The -n/--dry-run flag will run rsync in dry‑run mode and simply show
    what would be copied; this is useful for validating paths before
    making changes.
You can also request a single item by name.
EOF
}

# command-line dispatcher
main() {
  # parse global flags
  if [[ $# -gt 0 ]]; then
    case "$1" in
    -n | --dry-run)
      DRY_RUN=true
      shift
      ;;
    esac
  fi

  if [[ $# -eq 0 ]] || [[ "$1" == "all" ]]; then
    sync_all
    return
  fi

  case "$1" in
  syncthing)
    copy_from_main "$SYNCTHING_SRC" "$SYNCTHING_DIR"
    ;;
  browser)
    copy_from_main "$BROWSER_SRC" "$BROWSER_DIR"
    ;;
  documents)
    copy_from_main "$DOCUMENTS_SRC" "$DOCUMENTS_DIR"
    ;;
  zed)
    copy_from_main "$ZED_SRC" "$ZED_DIR"
    ;;
  keyrings)
    copy_from_main "$KEYRINGS_SRC" "$KEYRINGS_DIR"
    ;;
  dotfiles)
    copy_from_main "$DOTFILES_SRC" "$DOTFILES_DIR"
    ;;
  freetube)
    copy_from_main "$FreeTube_SRC" "$FreeTube_DIR"
    ;;
  fonts)
    copy_from_main "$FONTS_SRC" "$FONTS_DIR"
    ;;
  pictures)
    copy_from_main "$PICTURES_SRC" "$PICTURES_DIR"
    ;;
  photos)
    copy_from_main "$PHOTOS_SRC" "$PHOTOS_DIR"
    ;;
  videos)
    copy_from_main "$VIDEOS_SRC" "$VIDEOS_DIR"
    ;;
  zoxidedb)
    copy_from_main "$ZOXIDEDB_SRC" "$ZOXIDEDB_DIR"
    ;;
  easyeffects)
    copy_from_main "$EASY_EFFECT_SRC" "$EASY_EFFECT_DIR"
    ;;
  *)
    echo "Unknown target: $1" >&2
    usage
    exit 1
    ;;
  esac
}

# entry point
main "$@"
