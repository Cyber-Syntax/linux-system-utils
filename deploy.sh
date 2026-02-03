#!/usr/bin/env bash
#
# Linux System Utils Deployment Script
# Deploys scripts to XDG base directories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default locations based on XDG Base Directory Specification
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Binary installation directory
BIN_DIR="${HOME}/.local/bin"

# Repo and installation directories
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${XDG_DATA_HOME}/linux-system-utils"
CONFIG_DIR="${XDG_CONFIG_HOME}/linux-system-utils"

# Define script categories and their installation paths
declare -A SCRIPT_DIRS
SCRIPT_DIRS["system"]="${INSTALL_DIR}/system"
SCRIPT_DIRS["github"]="${INSTALL_DIR}/github"
SCRIPT_DIRS["hardware"]="${INSTALL_DIR}/hardware"
SCRIPT_DIRS["games"]="${INSTALL_DIR}/games"
SCRIPT_DIRS["audio"]="${INSTALL_DIR}/audio"
SCRIPT_DIRS["display"]="${INSTALL_DIR}/display"
SCRIPT_DIRS["automation"]="${INSTALL_DIR}/automation"
SCRIPT_DIRS["general"]="${INSTALL_DIR}/general"
SCRIPT_DIRS["network"]="${INSTALL_DIR}/network"
SCRIPT_DIRS["package-management"]="${INSTALL_DIR}/package-management"
SCRIPT_DIRS["power"]="${INSTALL_DIR}/power"

# Print usage information
print_usage() {
  echo -e "${BLUE}Linux System Utils - Deployment Script${NC}"
  echo
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  -h, --help        Show this help message"
  echo "  -m, --main        Install from main branch"
  echo "  -f, --force       Force installation (overwrite existing files)"
  echo "  -v, --verbose     Verbose output"
  echo "  -t, --target DIR  Specify custom installation directory"
  echo "  -b, --binary      Install changelog.sh as a global binary to ~/.local/bin"
  echo
  echo "Installation directory: $INSTALL_DIR"
  echo
  echo "Examples:"
  echo "  $0                # Install from current directory (default)"
  echo "  $0 --main         # Install from main branch"
  echo "  $0 --target ~/scripts # Install to custom directory"
}

# Log messages with colors based on type
log_info() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo -e "${BLUE}[INFO]${NC} $1"
  fi
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Create directory if it doesn't exist
ensure_dir_exists() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    log_info "Creating directory: $dir"
    mkdir -p "$dir"
  fi
}

# Copy script with proper permissions
copy_script() {
  local src="$1"
  local dest="$2"
  local base_dest_dir="$(dirname "$dest")"

  ensure_dir_exists "$base_dest_dir"

  if [[ -f "$dest" && "$FORCE" != "true" ]]; then
    log_warn "File already exists: $dest (use --force to overwrite)"
    return 0
  fi

  cp "$src" "$dest"
  chmod +x "$dest"
  log_info "Installed: $dest"
}

# Install binaries to ~/.local/bin
# Binaries: changelog.sh, copy_agents.sh
install_binaries() {
  ensure_dir_exists "$BIN_DIR"

  local changelog_src="${INSTALL_DIR}/github/changelog.sh"
  local copy_agents_src="${INSTALL_DIR}/github/copy_agents.sh"

  if [[ -f "$changelog_src" ]]; then
    copy_script "$changelog_src" "${BIN_DIR}/changelog"
    log_success "Installed changelog command to: ${BIN_DIR}/changelog"
  else
    log_warn "changelog.sh not found in installation directory"
  fi

  if [[ -f "$copy_agents_src" ]]; then
    copy_script "$copy_agents_src" "${BIN_DIR}/copy_agents"
    log_success "Installed copy_agents command to: ${BIN_DIR}/copy_agents"
  else
    log_warn "copy_agents.sh not found in installation directory"
  fi
}

# Install from current directory
install_from_current() {
  log_info "Installing from current directory..."

  # Create installation directories
  ensure_dir_exists "$INSTALL_DIR"
  ensure_dir_exists "$CONFIG_DIR"

  # Get current branch for logging
  local current_branch="$(cd "$REPO_DIR" && git branch --show-current 2>/dev/null || echo 'unknown')"
  log_info "Installing from branch: $current_branch"

  # Copy entire folders from the current directory to INSTALL_DIR
  for dir in "${!SCRIPT_DIRS[@]}"; do
    local source_dir="${REPO_DIR}/${dir}"
    local target_dir="${SCRIPT_DIRS[$dir]}"

    if [[ -d "$source_dir" ]]; then
      ensure_dir_exists "$target_dir"
      # Copy all contents including hidden files
      shopt -s dotglob
      cp -r "$source_dir"/* "$target_dir"/ 2>/dev/null || true
      log_info "Copied folder: $source_dir -> $target_dir"

      # Log each copied file
      find "$target_dir" -type f 2>/dev/null | while read -r file; do
        local rel_path="${file#"$target_dir"/}"
        log_info "  File: $rel_path -> $file"
      done
    else
      log_warn "Directory not found: $source_dir"
    fi
  done

  # Ensure all scripts are executable
  find "$INSTALL_DIR" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -exec chmod +x {} \;

  log_success "Installation from current directory complete!"
  log_info "Files installed to: $INSTALL_DIR"
  log_info "Branch used: $current_branch"
  log_info "Run scripts from: $INSTALL_DIR/<folder>/<subpath>/<script>"
  log_info "Note: Re-run deploy to update after making changes"
}

# Install from main branch by cloning directly to the installation directory
install_from_main() {
  log_info "Installing from main branch..."

  # Check if git is available
  if ! command_exists git; then
    log_error "Git is not installed. Please install git first."
    exit 1
  fi

  # Clean installation directory if it exists and force is enabled
  if [[ -d "$INSTALL_DIR" ]]; then
    if [[ "$FORCE" == "true" ]]; then
      log_info "Removing existing installation directory..."
      rm -rf "$INSTALL_DIR"
    else
      log_warn "Installation directory already exists: $INSTALL_DIR"
      log_warn "Use --force to reinstall from main branch"
      exit 1
    fi
  fi

  # Create parent directories
  ensure_dir_exists "$(dirname "$INSTALL_DIR")"

  # Clone directly to the installation directory
  local repo_url="https://github.com/cyber-syntax/linux-system-utils.git"
  log_info "Cloning repository to: $INSTALL_DIR"

  if ! git clone --depth 1 --branch main "$repo_url" "$INSTALL_DIR"; then
    log_error "Failed to clone repository."
    exit 1
  fi

  # Remove unwanted folders
  local unwanted_dirs=("nvidia" "web-scrapping" "backup" "containers")
  for unwanted in "${unwanted_dirs[@]}"; do
    if [[ -d "$INSTALL_DIR/$unwanted" ]]; then
      rm -rf "$INSTALL_DIR/$unwanted"
      log_info "Removed unwanted folder: $unwanted"
    fi
  done

  # Ensure all scripts are executable
  find "$INSTALL_DIR" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -exec chmod +x {} \;

  # Check if we have the expected directory structure (should be true after removing unwanted)
  local has_expected_structure=true
  for dir in "${!SCRIPT_DIRS[@]}"; do
    if [[ ! -d "$INSTALL_DIR/$dir" ]]; then
      has_expected_structure=false
      break
    fi
  done

  if [[ "$has_expected_structure" == "false" ]]; then
    log_warn "Repository structure differs from expected after cleanup."
  fi

  log_success "Main branch installation complete!"
  log_info "Folders installed to: $INSTALL_DIR"
  log_info "Run scripts from: $INSTALL_DIR/<folder>/<subpath>/<script>"
}

# Parse command-line arguments
MODE="current" # Default mode is current directory
FORCE="false"
VERBOSE="false"
CUSTOM_INSTALL_DIR=""
INSTALL_BINARY="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    print_usage
    exit 0
    ;;
  -m | --main)
    MODE="main"
    shift
    ;;
  -f | --force)
    FORCE="true"
    shift
    ;;
  -v | --verbose)
    VERBOSE="true"
    shift
    ;;
  -t | --target)
    if [[ -n "$2" ]]; then
      CUSTOM_INSTALL_DIR="$2"
      INSTALL_DIR="$CUSTOM_INSTALL_DIR"
      shift 2
    else
      log_error "Option --target requires a directory argument."
      exit 1
    fi
    ;;
  -b | --binary)
    INSTALL_BINARY="true"
    shift
    ;;
  *)
    log_error "Unknown option: $1"
    print_usage
    exit 1
    ;;
  esac
done

# Run installation based on selected mode
if [[ "$MODE" == "main" ]]; then
  install_from_main
else
  install_from_current
fi

# Install binaries if requested
if [[ "$INSTALL_BINARY" == "true" ]]; then
  install_binaries
fi

exit 0
