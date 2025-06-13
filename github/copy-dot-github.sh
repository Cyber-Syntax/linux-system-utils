bin/bash
# Script to copy the .github folder from this repository to a list of other repositories

# Set source directory for .github folder
SOURCE_DIR="$(dirname "$(realpath "$0")")/.github"

# Define list of target repositories
# Add or remove repositories as needed
TARGET_REPOS=(
  "/home/developer/Documents/repository/my-unicorn"
  "/home/developer/Documents/repository/AutoTarCompress"
  "/home/developer/Documents/repository/fedora-setup"
  "/home/developer/Documents/repository/BatteryGuardian"
  "/home/developer/Documents/repository/WallpaperChanger"
)

# Colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define repo-specific files/folders that should not be overwritten if they exist
REPO_SPECIFIC_FILES=(
  "ISSUE_TEMPLATE/bug_report.md"
  "ISSUE_TEMPLATE/feature_request.md"
  "CONTRIBUTING.md"
  "CONTRIBUTING.tr.md"
  "CODE_OF_CONDUCT.md"
)

# Define general files/folders that should always be copied
GENERAL_FILES=(
  "FUNDING.yml"
  "workflows"
)

# Function to copy .github folder to a target repository
copy_github_folder() {
  local target_repo="$1"
  local target_dir="${target_repo}/.github"

  echo -e "${YELLOW}Processing .github for:${NC} ${target_repo}"

  # Check if target repository exists
  if [ ! -d "$target_repo" ]; then
    echo -e "  ${RED}Error: Target repository does not exist:${NC} ${target_repo}"
    return 1
  fi

  # Create target .github directory if it doesn't exist
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    echo -e "  ${YELLOW}Created new .github directory in:${NC} ${target_repo}"
  else
    echo -e "  ${YELLOW}Found existing .github directory in:${NC} ${target_repo}"
  fi

  # Create ISSUE_TEMPLATE directory if it doesn't exist
  if [ ! -d "$target_dir/ISSUE_TEMPLATE" ] && [ -d "$SOURCE_DIR/ISSUE_TEMPLATE" ]; then
    mkdir -p "$target_dir/ISSUE_TEMPLATE"
  fi

  # Copy repo-specific files only if they don't exist in the target
  for file in "${REPO_SPECIFIC_FILES[@]}"; do
    if [ -e "$SOURCE_DIR/$file" ] && [ ! -e "$target_dir/$file" ]; then
      # Create parent directory if needed
      parent_dir=$(dirname "$target_dir/$file")
      if [ ! -d "$parent_dir" ]; then
        mkdir -p "$parent_dir"
      fi

      # Copy the file
      cp -r "$SOURCE_DIR/$file" "$target_dir/$file"
      echo -e "  ${GREEN}Copied $file${NC} (not previously present)"
    elif [ -e "$target_dir/$file" ]; then
      echo -e "  ${YELLOW}Skipped $file${NC} (already exists in target)"
    fi
  done

  # Always copy general files (overwrite if they exist)
  for file in "${GENERAL_FILES[@]}"; do
    if [ -e "$SOURCE_DIR/$file" ]; then
      # Create parent directory if needed
      parent_dir=$(dirname "$target_dir/$file")
      if [ ! -d "$parent_dir" ]; then
        mkdir -p "$parent_dir"
      fi

      # Use -r for directories
      if [ -d "$SOURCE_DIR/$file" ]; then
        # For directories, we need to make sure the directory exists first
        if [ ! -d "$target_dir/$file" ]; then
          mkdir -p "$target_dir/$file"
        fi
        # Copy all contents of the directory
        cp -r "$SOURCE_DIR/$file"/* "$target_dir/$file"
      else
        cp "$SOURCE_DIR/$file" "$target_dir/$file"
      fi
      echo -e "  ${GREEN}Copied/Updated $file${NC}"
    fi
  done

  echo -e "  ${GREEN}Successfully processed .github for:${NC} ${target_repo}"
  return 0
}

# Main function
main() {
  # Check if source directory exists
  if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source .github directory not found:${NC} ${SOURCE_DIR}"
    exit 1
  fi

  echo -e "${GREEN}Source .github directory:${NC} ${SOURCE_DIR}"
  echo -e "${YELLOW}Starting to copy .github folder to target repositories...${NC}"
  echo ""

  # Counter variables
  local success_count=0
  local fail_count=0

  # Iterate through all target repositories
  for repo in "${TARGET_REPOS[@]}"; do
    if copy_github_folder "$repo"; then
      ((success_count++))
    else
      ((fail_count++))
    fi
    echo ""
  done

  # Summary
  echo -e "${GREEN}Summary:${NC}"
  echo -e "  ${GREEN}Successfully copied to:${NC} ${success_count} repositories"
  if [ $fail_count -gt 0 ]; then
    echo -e "  ${RED}Failed to copy to:${NC} ${fail_count} repositories"
  fi
}

# Run the main function
main
