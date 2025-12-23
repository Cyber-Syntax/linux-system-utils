#!/usr/bin/env bash
# Written for obsidian vault
# to fix spaces in file and directory names

set -euo pipefail # Exit on error, undefined variables, and pipe failures

# Configuration
VAULT_DIR="/home/developer/Documents/obsidian/main-vault"
DRY_RUN=true
RENAMED_COUNT=0
ERROR_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Example transformations:
# Folder: "programming notes" -> "programming-notes"
# File: "bash scripting.md" -> "bash-scripting.md"

print_usage() {
  echo "Usage: $0 [--dry-run | --execute]"
  echo ""
  echo "Options:"
  echo "  --dry-run    Preview changes without actually renaming (default)"
  echo "  --execute    Execute the renaming operation"
  echo ""
  echo "This script will rename all files and directories in the Obsidian vault"
  echo "by replacing spaces with dashes (-) for better management."
  exit 1
}

print_header() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}  Obsidian Vault Renaming Tool${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo -e "Vault Directory: ${YELLOW}${VAULT_DIR}${NC}"
  if [ "$DRY_RUN" = true ]; then
    echo -e "Mode: ${YELLOW}DRY RUN (no changes will be made)${NC}"
  else
    echo -e "Mode: ${RED}EXECUTE (files will be renamed)${NC}"
  fi
  echo ""
}

check_directory() {
  if [ ! -d "$VAULT_DIR" ]; then
    echo -e "${RED}Error: Vault directory does not exist: $VAULT_DIR${NC}" >&2
    exit 1
  fi
}

rename_item() {
  local item="$1"
  local item_type="$2" # "file" or "directory"

  # Get the directory path and basename
  local dir_path=$(dirname "$item")
  local base_name=$(basename "$item")

  # Check if basename contains spaces
  if [[ "$base_name" != *" "* ]]; then
    return 0 # No spaces, nothing to do
  fi

  # Create new name by replacing spaces with dashes
  local new_base_name=$(echo "$base_name" | tr ' ' '-')
  local new_item="$dir_path/$new_base_name"

  # Display the change
  if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}[DRY RUN]${NC} Would rename $item_type:"
    echo -e "  From: ${YELLOW}$item${NC}"
    echo -e "  To:   ${GREEN}$new_item${NC}"
    RENAMED_COUNT=$((RENAMED_COUNT + 1))
  else
    # Attempt to rename
    if mv "$item" "$new_item" 2>/dev/null; then
      echo -e "${GREEN}[SUCCESS]${NC} Renamed $item_type:"
      echo -e "  From: ${YELLOW}$item${NC}"
      echo -e "  To:   ${GREEN}$new_item${NC}"
      RENAMED_COUNT=$((RENAMED_COUNT + 1))
    else
      echo -e "${RED}[ERROR]${NC} Failed to rename $item_type: $item" >&2
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
  fi
}

process_vault() {
  cd "$VAULT_DIR" || exit 1

  echo -e "${BLUE}Processing directories (deepest first)...${NC}"
  echo ""

  # First, rename directories from deepest to shallowest
  # Using -depth option to process child directories before parents
  # This prevents path issues when parent directories are renamed
  while IFS= read -r -d $'\0' dir; do
    rename_item "$dir" "directory"
  done < <(find . -mindepth 1 -depth -type d -print0)

  echo ""
  echo -e "${BLUE}Processing markdown files...${NC}"
  echo ""

  # Then, rename all .md files
  while IFS= read -r -d $'\0' file; do
    rename_item "$file" "file"
  done < <(find . -type f -name "*.md" -print0)
}

print_summary() {
  echo ""
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}  Summary${NC}"
  echo -e "${BLUE}========================================${NC}"

  if [ "$DRY_RUN" = true ]; then
    echo -e "Items that ${YELLOW}would be renamed${NC}: ${GREEN}$RENAMED_COUNT${NC}"
  else
    echo -e "Items ${GREEN}successfully renamed${NC}: $RENAMED_COUNT"
    if [ $ERROR_COUNT -gt 0 ]; then
      echo -e "Items with ${RED}errors${NC}: $ERROR_COUNT"
    fi
  fi
  echo ""
}

confirm_execution() {
  if [ "$DRY_RUN" = true ] && [ $RENAMED_COUNT -gt 0 ]; then
    echo -e "${YELLOW}To execute these changes, run:${NC}"
    echo -e "  $0 --execute"
    echo ""
  fi
}

# Main execution
main() {
  # Parse command line arguments
  if [ $# -gt 0 ]; then
    case "$1" in
    --dry-run)
      DRY_RUN=true
      ;;
    --execute)
      DRY_RUN=false
      ;;
    --help | -h)
      print_usage
      ;;
    *)
      echo -e "${RED}Error: Unknown option '$1'${NC}" >&2
      print_usage
      ;;
    esac
  fi

  print_header
  check_directory

  # If executing, ask for confirmation
  if [ "$DRY_RUN" = false ]; then
    echo -e "${RED}WARNING: This will rename files and directories in your vault!${NC}"
    echo -e "Press ${YELLOW}Ctrl+C${NC} to cancel or ${GREEN}Enter${NC} to continue..."
    read -r
    echo ""
  fi

  process_vault
  print_summary
  confirm_execution
}

main "$@"
