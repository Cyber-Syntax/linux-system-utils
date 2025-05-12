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
XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Repo and installation directories
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${XDG_DATA_HOME}/linux-system-utils"
BIN_DIR="${XDG_BIN_HOME}"
CONFIG_DIR="${XDG_CONFIG_HOME}/linux-system-utils"

# Define script categories and their installation paths
declare -A SCRIPT_DIRS
SCRIPT_DIRS["system/info"]="${INSTALL_DIR}/system/info"
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
  echo "  -d, --dev         Install from current directory (development mode)"
  echo "  -m, --main        Install from main branch (default)"
  echo "  -f, --force       Force installation (overwrite existing files)"
  echo "  -v, --verbose     Verbose output"
  echo "  -t, --target DIR  Specify custom installation directory"
  echo
  echo "Example:"
  echo "  $0 --dev          # Install from current directory"
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
  command -v "$1" &> /dev/null
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

# Create symbolic links in bin directory
create_symlinks() {
  ensure_dir_exists "$BIN_DIR"

  # Find all executable scripts
  find "$INSTALL_DIR" -type f -name "*.sh" | while read script; do
    local script_name="$(basename "$script" .sh)"
    local link_path="$BIN_DIR/$script_name"

    # Skip if link exists and not forcing
    if [[ -L "$link_path" && "$FORCE" != "true" ]]; then
      log_warn "Symlink already exists: $link_path (use --force to overwrite)"
      continue
    fi

    # Remove existing symlink or file if it exists
    if [[ -e "$link_path" ]]; then
      rm "$link_path"
    fi

    ln -sf "$script" "$link_path"
    log_info "Created symlink: $link_path -> $script"
  done
}

# Install from current directory (development mode)
install_from_dev() {
  log_info "Installing from development directory..."

  # Create installation directories
  ensure_dir_exists "$INSTALL_DIR"
  ensure_dir_exists "$CONFIG_DIR"

  # Install scripts by category
  for dir in "${!SCRIPT_DIRS[@]}"; do
    local source_dir="${REPO_DIR}/${dir}"
    local target_dir="${SCRIPT_DIRS[$dir]}"

    if [[ -d "$source_dir" ]]; then
      ensure_dir_exists "$target_dir"

      # Find all shell scripts in this category
      find "$source_dir" -type f -name "*.sh" | while read script; do
        local script_name="$(basename "$script")"
        copy_script "$script" "${target_dir}/${script_name}"
      done
    else
      log_warn "Directory not found: $source_dir"
    fi
  done

  # Create symlinks for easy access
  create_symlinks

  log_success "Development installation complete!"
  log_info "Scripts installed to: $INSTALL_DIR"
  log_info "Symlinks created in: $BIN_DIR"
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

  # Reorganize files if needed - if the repository structure doesn't match our expected structure
  # Check if we have the expected directory structure
  local has_expected_structure=true
  for dir in "${!SCRIPT_DIRS[@]}"; do
    if [[ ! -d "$INSTALL_DIR/$dir" ]]; then
      has_expected_structure=false
      break
    fi
  done

  if [[ "$has_expected_structure" == "false" ]]; then
    log_info "Repository structure differs from expected. Reorganizing..."

    # Create a temporary directory for reorganization
    local temp_dir="$(mktemp -d)"

    # Look for script files in the repository and move them to the appropriate category
    find "$INSTALL_DIR" -type f -name "*.sh" | while read script; do
      local script_name="$(basename "$script")"
      local script_path="$(dirname "$script")"

      # Determine script category from path or content
      local category=""
      if [[ "$script_path" == *"/system/info"* ]]; then
        category="system/info"
      elif [[ "$script_path" == *"/package-management"* ]]; then
        category="package-management"
      elif [[ "$script_path" == *"/power"* ]]; then
        category="power"
      else
        # Default category based on script name or content
        if [[ "$script_name" == *"storage"* ]]; then
          category="system/info"
        elif [[ "$script_name" == *"package"* || "$script_name" == *"flatpak"* ]]; then
          category="package-management"
        elif [[ "$script_name" == *"power"* || "$script_name" == *"bright"* ]]; then
          category="power"
        else
          # Examine content for hints about category
          if grep -q "storage\|disk\|memory\|cpu" "$script"; then
            category="system/info"
          elif grep -q "package\|dnf\|apt\|flatpak" "$script"; then
            category="package-management"
          elif grep -q "power\|battery\|brightness\|suspend" "$script"; then
            category="power"
          else
            # If we can't determine, put in a misc category
            category="misc"
          fi
        fi
      fi

      # Create category directory in temp dir
      ensure_dir_exists "$temp_dir/$category"

      # Copy script to temp directory
      cp "$script" "$temp_dir/$category/"
      chmod +x "$temp_dir/$category/$script_name"
    done

    # Clean installation directory except .git
    find "$INSTALL_DIR" -mindepth 1 -not -path "$INSTALL_DIR/.git*" -delete

    # Move reorganized files back to installation directory
    cp -r "$temp_dir/"* "$INSTALL_DIR/"

    # Clean up
    rm -rf "$temp_dir"
  fi

  # Create symlinks for easy access
  create_symlinks

  log_success "Main branch installation complete!"
  log_info "Scripts installed to: $INSTALL_DIR"
  log_info "Symlinks created in: $BIN_DIR"
}

# Parse command-line arguments
MODE="main"  # Default mode is main branch
FORCE="false"
VERBOSE="false"
CUSTOM_INSTALL_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_usage
      exit 0
      ;;
    -d|--dev)
      MODE="dev"
      shift
      ;;
    -m|--main)
      MODE="main"
      shift
      ;;
    -f|--force)
      FORCE="true"
      shift
      ;;
    -v|--verbose)
      VERBOSE="true"
      shift
      ;;
    -t|--target)
      if [[ -n "$2" ]]; then
        CUSTOM_INSTALL_DIR="$2"
        INSTALL_DIR="$CUSTOM_INSTALL_DIR"
        shift 2
      else
        log_error "Option --target requires a directory argument."
        exit 1
      fi
      ;;
    *)
      log_error "Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

# Run installation based on selected mode
if [[ "$MODE" == "dev" ]]; then
  install_from_dev
else
  install_from_main
fi

exit 0