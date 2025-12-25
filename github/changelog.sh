#!/usr/bin/env bash
#
# Self-contained changelog generator that uses only git.
#
# - Detects the default branch (main/master or origin/HEAD fallback)
# - Compares the current branch to the default branch
# - Builds a changelog entry (date, branch, commit summaries, changed files)
# - Prompts the user and prepends the entry to CHANGELOG.md
#
# Usage:
#   ./scripts/changelog.bash [optional notes to include in the entry]
#
# Exit codes:
#   0 - success (or nothing to do)
#   1 - error
#

set -o pipefail
set -o errexit
[[ ${DEBUG-} ]] && set -o xtrace

# Basic logging helpers
_log() { printf "%s\n" "$*" >&2; }
info() { _log "[INFO]  $*"; }
warn() { _log "[WARN]  $*"; }
error() { _log "[ERROR] $*"; }
success() { _log "[OK]    $*"; }

function print_usage() {
  cat <<EOF
Usage: $(basename "$0") [notes...]

Generate or update CHANGELOG_commits.md based on changes on the current branch
relative to the repository's default branch.

Optional arguments are treated as freeform notes to include in the entry.

Examples:
  $(basename "$0")
  $(basename "$0") "Only include client/ directory changes"
EOF
}

# Ctrl-C handling
function ctrlc_trap() {
  _log ""
  warn "Script interrupted. Exiting."
  exit 130
}
trap ctrlc_trap SIGINT

# Help
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_usage
  exit 0
fi

# Ensure we're inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  error "Not inside a git repository."
  exit 1
fi

# Determine default branch: prefer local main/master, else try origin/HEAD
default_branch=""
if git show-ref --quiet refs/heads/main; then
  default_branch="main"
elif git show-ref --quiet refs/heads/master; then
  default_branch="master"
else
  # Try to read what origin/HEAD points to
  if origin_head=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null); then
    # output like "origin/main" -> strip "origin/"
    default_branch="${origin_head#origin/}"
  fi
fi

if [[ -z "${default_branch}" ]]; then
  error "Could not determine default branch (no main/master and no origin/HEAD)."
  exit 1
fi
info "Default branch: ${default_branch}"

# Current branch
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
  error "Failed to determine current branch."
  exit 1
}
info "Current branch: ${current_branch}"

if [[ "${current_branch}" == "${default_branch}" ]]; then
  warn "Current branch is the default branch (${default_branch}). Nothing to do."
  exit 0
fi

# Build git range. Use the three-dot range to compare branch against merge base.
git_range="${default_branch}...${current_branch}"

# Get commits between default and current
info "Collecting commits between ${default_branch} and ${current_branch}..."
commits=$(git rev-list --reverse "${git_range}" 2>/dev/null)
if [[ -z "$commits" ]]; then
  warn "No commits on ${current_branch} relative to ${default_branch}."
  exit 0
fi

# Commit entries with body and files
commit_summaries=""
for commit in $commits; do
  short_hash=$(git rev-parse --short "$commit")
  author=$(git log -1 --pretty=format:'%an' "$commit")
  subject=$(git log -1 --pretty=format:'%s' "$commit")
  body=$(git log -1 --pretty=format:'%b' "$commit")
  commit_summaries+="- ${short_hash} ${subject} (${author})"$'\n'
  # If body non-empty (ignoring pure whitespace), indent each body line
  if [[ -n "${body// /}" ]]; then
    while IFS= read -r bl; do
      commit_summaries+="    ${bl}"$'\n'
    done <<<"$(printf '%s' "${body}")"
  fi
  # Files changed in this commit
  file_changes_raw=$(git show --name-status --pretty="" "$commit")
  if [[ -n "$file_changes_raw" ]]; then
    commit_summaries+="    Files changed:"$'\n'
    while IFS= read -r line; do
      if [[ -z "$line" ]]; then continue; fi
      status=$(printf "%s" "${line}" | awk '{print $1}')
      rest=$(printf "%s" "${line}" | cut -f2-)
      case "${status:0:1}" in
      A)
        verb="Added"
        file="${rest}"
        ;;
      M)
        verb="Modified"
        file="${rest}"
        ;;
      D)
        verb="Deleted"
        file="${rest}"
        ;;
      R) # rename: rest contains "old<TAB>new" - preserve new name
        # We try to extract the last field as new path
        new_path=$(printf "%s" "${rest}" | awk -F $'\t' '{print $NF}')
        old_path=$(printf "%s" "${rest}" | awk -F $'\t' '{print $(NF-1)}')
        verb="Renamed"
        file="${old_path} -> ${new_path}"
        ;;
      C)
        verb="Copied"
        file="${rest}"
        ;;
      *)
        verb="${status}"
        file="${rest}"
        ;;
      esac
      commit_summaries+="      - ${verb}: ${file}"$'\n'
    done <<<"${file_changes_raw}"
  fi
  commit_summaries+=$'\n'
done

# Optional user-supplied notes (all args)
if [[ $# -gt 0 ]]; then
  notes="$*"
else
  notes=""
fi

# Prepare the changelog entry
entry_date=$(date -u +"%Y-%m-%d")
entry_header="## ${current_branch} - ${entry_date}"
entry_separator=""
entry_builder=""
entry_builder+="${entry_header}"$'\n'
entry_builder+=""$'\n'
if [[ -n "${notes}" ]]; then
  entry_builder+="Notes: ${notes}"$'\n'$'\n'
fi
entry_builder+="Summary of commits:"$'\n'
entry_builder+="${commit_summaries}"

# Final entry variable
changelog_entry="${entry_builder}"

# Path to CHANGELOG_commits.md in the repository root (repo root = git rev-parse --show-toplevel)
repo_root=$(git rev-parse --show-toplevel)
changelog_path="${repo_root}/CHANGELOG_commits.md"

# Preview the entry (first ~200 lines)
info "Preview of generated changelog entry:"
printf '%s\n' "------------------------------------------------------------"
printf '%s\n' "${changelog_entry}"
printf '%s\n' "------------------------------------------------------------"

# Confirm with the user
printf "\nDo you want to prepend this entry to %s ? [y/N]: " "${changelog_path}"
read -r yn
case "${yn}" in
[yY] | [yY][eE][sS]) ;;
*)
  warn "Aborted by user. No changes written."
  exit 0
  ;;
esac

# Ensure CHANGELOG exists (create if needed)
if [[ ! -f "${changelog_path}" ]]; then
  info "Creating new ${changelog_path}"
  : >"${changelog_path}" || {
    error "Failed to create ${changelog_path}"
    exit 1
  }
fi

# Prepend the entry safely using a temp file
tmpfile=$(mktemp "${TMPDIR:-/tmp}/changelog.XXXXXX") || {
  error "Failed to create a temporary file."
  exit 1
}
# Write new entry then existing content
{
  printf '%s\n' "${changelog_entry}"
  printf '%s\n' "$(cat "${changelog_path}")"
} >"${tmpfile}" || {
  rm -f "${tmpfile}"
  error "Failed writing to temporary file."
  exit 1
}

# Move into place
if mv "${tmpfile}" "${changelog_path}"; then
  success "CHANGELOG_commits.md updated at ${changelog_path}"
else
  rm -f "${tmpfile}"
  error "Failed to update ${changelog_path}"
  exit 1
fi

# Show the top of the updated changelog for verification
printf '\n%s\n' "Top of ${changelog_path}:"
echo "------------------------------------------------------------"
head -n 60 "${changelog_path}"
echo "------------------------------------------------------------"

exit 0
