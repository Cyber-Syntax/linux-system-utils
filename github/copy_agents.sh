#!/usr/bin/env bash
#
# Script to copy instruction/prompt/agent files from awesome-copilot global repo
# to my personal github repo because I have some customizations there.
#
#
# Global repo: ~/Documents/global-repos/awesome-copilot
# My github repo: ~/Documents/my-repos/copilot-instructions
#
# Agents to copy:
# ├── instructions/
# │  ├── python.instructions.md
# │  ├── shell.instructions.md
# │  ├── prompt.instructions.md
# │  ├── instructions.instructions.md
# │  └── github-actions-ci-cd-best-practices.instructions.md
# ├── agents/
# │  ├── critical-thinking.agent.md
# │  ├── principal-software-engineer.agent.md
# │  ├── janitor.agent.md
# │  ├── expert-cpp-software-engineer.chatmode.md
# │  ├── debug.agent.md
# │  ├── mentor.agent.md
# │  ├── se-security-reviewer.agent.md
# │  ├── se-system-architecture-reviewer.agent.md
# │  ├── github-actions-expert.agent.md
# │  ├── prd.chatmode.md
# │  ├── prompt-engineer.agent.md
# │  ├── adr-generator.agent.md
# │  ├── implementation-plan.agent.md
# │  ├── plan.agent.md
# │  ├── gpt-5-beast-mode.agent.md
# │  ├── 4.1-Beast.agent.md
# │  ├── software-engineer-agent-v1.agent.md
# │  ├── hlbpa.agent.md
# │  ├── Thinking-Beast-Mode.agent.md
# │  ├── prompt-builder.agent.md
# │  └── Ultimate-Transparent-Thinking-Beast-Mode.agent.md
# ├── prompts/
# │  ├── docs.prompt.md
# │  ├── review-and-refactor.prompt.md
# │  ├── boost-prompt.prompt.md
# │  ├── create-github-issue-feature-from-specification.prompt.md
# │  ├── pytest-coverage.prompt.md
# │  ├── create-readme.prompt.md
# │  ├── python-pep8.prompt.md
# │  ├── conventional-commit.prompt.md
# │  ├── create-architectural-decision-record.prompt.md
# │  ├── refactor-decrease-lines.prompt.md
# │  ├── gilfoyle-code-review.prompt.md
# │  ├── add-educational-comments.prompt.md
# │  ├── update-implementation-plan.prompt.md
# │  ├── code-exemplars-blueprint-generator.prompt.md
# │  ├── update-oo-component-documentation.prompt.md
# │  ├── create-oo-component-documentation.prompt.md
# │  ├── create-agentsmd.prompt.md
# │  ├── generate-custom-instructions-from-codebase.prompt.md
# │  ├── technology-stack-blueprint-generator.prompt.md
# │  ├── memory-bank.prompt.md
# │  ├── spec-driven-workflow-v1.prompt.md
# │  ├── tldr-prompt.prompt.md
# │  ├── architecture-blueprint-generator.prompt.md
# │  ├── folder-structure-blueprint-generator.prompt.md
# │  ├── copilot-instructions-blueprint-generator.prompt.md
# │  ├── write-coding-standards-from-file.prompt.md
# │  └── performance-optimization.prompt.md
#
# Workflow:
# 1. Go global repo and git pull latest changes
# 2. Check if any of the above files have been updated in the global repo
# 3. If yes; copy those files from awesome-copilot repo to copilot-instructions repo
# 4. Print summary of copied files
#
# Rules:
# - Overwrite existing files in my github repo with the copied files
# - Print a summary of copied files
#
# Usage: ./copy_agents.sh

set -euo pipefail

# Repository paths
readonly AWESOME_COPILOT_REPO_PATH="$HOME/Documents/global-repos/awesome-copilot"
readonly MY_GITHUB_REPO_PATH="$HOME/Documents/my-repos/copilot-instructions"

# Files to copy organized by directory
readonly INSTRUCTION_FILES=(
  "python.instructions.md"
  "shell.instructions.md"
  "prompt.instructions.md"
  "instructions.instructions.md"
  "github-actions-ci-cd-best-practices.instructions.md"
)

readonly AGENT_FILES=(
  "critical-thinking.agent.md"
  "principal-software-engineer.agent.md"
  "janitor.agent.md"
  "debug.agent.md"
  "mentor.agent.md"
  "se-security-reviewer.agent.md"
  "se-system-architecture-reviewer.agent.md"
  "github-actions-expert.agent.md"
  "prompt-engineer.agent.md"
  "adr-generator.agent.md"
  "implementation-plan.agent.md"
  "plan.agent.md"
  "gpt-5-beast-mode.agent.md"
  "4.1-Beast.agent.md"
  "software-engineer-agent-v1.agent.md"
  "hlbpa.agent.md"
  "Thinking-Beast-Mode.agent.md"
  "prompt-builder.agent.md"
  "Ultimate-Transparent-Thinking-Beast-Mode.agent.md"
  "expert-cpp-software-engineer.agent.md"
  "prd.agent.md"
  "gilfoyle.agent.md"
)

readonly PROMPT_FILES=(
  "review-and-refactor.prompt.md"
  "boost-prompt.prompt.md"
  "create-github-issue-feature-from-specification.prompt.md"
  "pytest-coverage.prompt.md"
  "create-readme.prompt.md"
  "conventional-commit.prompt.md"
  "create-architectural-decision-record.prompt.md"
  "add-educational-comments.prompt.md"
  "update-implementation-plan.prompt.md"
  "code-exemplars-blueprint-generator.prompt.md"
  "update-oo-component-documentation.prompt.md"
  "create-oo-component-documentation.prompt.md"
  "create-agentsmd.prompt.md"
  "generate-custom-instructions-from-codebase.prompt.md"
  "technology-stack-blueprint-generator.prompt.md"
  "tldr-prompt.prompt.md"
  "architecture-blueprint-generator.prompt.md"
  "folder-structure-blueprint-generator.prompt.md"
  "copilot-instructions-blueprint-generator.prompt.md"
  "write-coding-standards-from-file.prompt.md"
)

# Copy full folder because skills are folder based
readonly SKILLS=(
  "prd"
  "refactor"
  "git-commit"
)

# Counters for summary
COPIED_COUNT=0
ERROR_COUNT=0

cleanup() {
  # No temporary resources to clean up in this script
  :
}

trap cleanup EXIT

validate_requirements() {
  if [[ ! -d "$AWESOME_COPILOT_REPO_PATH" ]]; then
    echo "Error: Global repo not found at $AWESOME_COPILOT_REPO_PATH" >&2
    exit 1
  fi

  if [[ ! -d "$MY_GITHUB_REPO_PATH" ]]; then
    echo "Error: Personal repo not found at $MY_GITHUB_REPO_PATH" >&2
    exit 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "Error: git command not found" >&2
    exit 1
  fi
}

pull_latest_changes() {
  echo "Pulling latest changes from global repo..."

  cd "$AWESOME_COPILOT_REPO_PATH" || {
    echo "Error: Failed to change to global repo directory" >&2
    return 1
  }

  if ! git pull origin main; then
    echo "Error: Failed to pull latest changes from global repo" >&2
    return 1
  fi

  echo "Successfully pulled latest changes"
}

files_differ() {
  local source_file="$1"
  local dest_file="$2"

  # If destination doesn't exist, files are different
  if [[ ! -f "$dest_file" ]]; then
    return 0
  fi

  # Compare files using diff
  if ! diff -q "$source_file" "$dest_file" >/dev/null 2>&1; then
    return 0 # Files are different
  else
    return 1 # Files are the same
  fi
}

copy_file() {
  local source_file="$1"
  local dest_file="$2"

  # Ensure destination directory exists
  local dest_dir
  dest_dir="$(dirname "$dest_file")"
  if [[ ! -d "$dest_dir" ]]; then
    if ! mkdir -p "$dest_dir"; then
      echo "  Error: Failed to create directory $dest_dir" >&2
      ((ERROR_COUNT += 1))
      return 1
    fi
  fi

  if cp "$source_file" "$dest_file"; then
    echo "  Copied: $(basename "$source_file")"
    ((COPIED_COUNT += 1))
  else
    echo "  Error: Failed to copy $(basename "$source_file")" >&2
    ((ERROR_COUNT += 1))
    return 1
  fi
}

directories_differ() {
  local source_dir="$1"
  local dest_dir="$2"

  # If destination doesn't exist, they differ
  if [[ ! -d "$dest_dir" ]]; then
    return 0
  fi

  # Compare directories recursively
  if ! diff -r -q "$source_dir" "$dest_dir" >/dev/null 2>&1; then
    return 0 # Different
  else
    return 1 # Same
  fi
}

copy_directory() {
  local source_dir="$1"
  local dest_dir="$2"

  # Ensure destination parent directory exists
  local dest_parent
  dest_parent="$(dirname "$dest_dir")"
  if [[ ! -d "$dest_parent" ]]; then
    if ! mkdir -p "$dest_parent"; then
      echo "  Error: Failed to create directory $dest_parent" >&2
      ((ERROR_COUNT += 1))
      return 1
    fi
  fi

  if cp -r "$source_dir" "$dest_dir"; then
    echo "  Copied: $(basename "$source_dir")/"
    ((COPIED_COUNT += 1))
  else
    echo "  Error: Failed to copy $(basename "$source_dir")" >&2
    ((ERROR_COUNT += 1))
    return 1
  fi
}

process_skills() {
  echo "Processing skills folders..."

  for skill in "${SKILLS[@]}"; do
    local source_dir="$AWESOME_COPILOT_REPO_PATH/skills/$skill"
    local dest_dir="$MY_GITHUB_REPO_PATH/skills/$skill"

    if [[ ! -d "$source_dir" ]]; then
      echo "  Warning: Source skill directory not found: $skill" >&2
      ((ERROR_COUNT += 1))
      continue
    fi

    if directories_differ "$source_dir" "$dest_dir"; then
      copy_directory "$source_dir" "$dest_dir"
    else
      echo "  Skipped: $skill (no changes)"
    fi
  done
}

process_files() {
  local source_dir="$1"
  local dest_dir="$2"
  local files=("${@:3}") # Remaining arguments are file names

  echo "Processing $source_dir files..."

  for file in "${files[@]}"; do
    local source_file="$AWESOME_COPILOT_REPO_PATH/$source_dir/$file"
    local dest_file="$MY_GITHUB_REPO_PATH/$dest_dir/$file"

    if [[ ! -f "$source_file" ]]; then
      echo "  Warning: Source file not found: $file" >&2
      ((ERROR_COUNT += 1))
      continue
    fi

    if files_differ "$source_file" "$dest_file"; then
      copy_file "$source_file" "$dest_file"
    else
      echo "  Skipped: $file (no changes)"
    fi
  done
}

print_summary() {
  echo "============================================================================"
  echo "Copy Summary"
  echo "============================================================================"
  echo "Files copied: $COPIED_COUNT"
  echo "Errors encountered: $ERROR_COUNT"

  if [[ $ERROR_COUNT -gt 0 ]]; then
    echo "Warning: Some operations failed. Please check the output above."
    exit 1
  else
    echo "All operations completed successfully."
  fi
}

main() {
  validate_requirements

  echo "============================================================================"
  echo "Copy Agent Files Script Started"
  echo "============================================================================"

  pull_latest_changes
  echo

  # Process each category of files
  process_files "instructions" "instructions" "${INSTRUCTION_FILES[@]}"
  echo

  process_files "agents" "agents" "${AGENT_FILES[@]}"
  echo

  process_files "prompts" "prompts" "${PROMPT_FILES[@]}"
  echo

  process_skills
  echo

  print_summary
}

# Execute main function
main "$@"
