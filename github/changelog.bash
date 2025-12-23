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
commit_count=$(git rev-list --count "${git_range}" 2>/dev/null || echo "0")
if [[ "${commit_count}" -eq 0 ]]; then
  warn "No commits on ${current_branch} relative to ${default_branch}."
  exit 0
fi

# Commit entries with body (subject + indented body)
commit_summaries=""
# Use NUL-separated commits to safely handle arbitrary commit bodies
# Use process substitution to avoid running the while loop in a subshell
while IFS= read -r -d $'\0' entry; do
  # entry lines:
  # 1: short hash
  # 2: author
  # 3: subject
  # 4..: body (may be empty)
  short_hash=$(printf '%s' "$entry" | sed -n '1p')
  author=$(printf '%s' "$entry" | sed -n '2p')
  subject=$(printf '%s' "$entry" | sed -n '3p')
  body=$(printf '%s' "$entry" | sed -n '4,$p')
  # Append header line
  commit_summaries+="${short_hash} ${subject} (${author})"$'\n'
  # If body non-empty (ignoring pure whitespace), indent each body line
  if [[ -n "${body// /}" ]]; then
    while IFS= read -r bl; do
      commit_summaries+="    ${bl}"$'\n'
    done <<<"$(printf '%s' "${body}")"
  fi
done < <(git --no-pager log --pretty=format:'%h%n%an%n%s%n%b%x00' "${git_range}")

# Changed files and statuses
file_changes_raw=$(git --no-pager diff --name-status "${git_range}")
# If diff returns nothing (shouldn't since commit_count > 0), guard it
if [[ -z "${file_changes_raw}" ]]; then
  file_changes="(no file list)"
else
  # Transform status codes into human readable lines
  # Example lines:
  #   A\tpath/to/file
  #   M\tpath/to/file
  #   D\tpath/to/file
  #   R100\told\tnew
  file_changes=""
  while IFS= read -r line; do
    # Split fields
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
    file_changes="${file_changes}- ${verb}: ${file}"$'\n'
  done <<<"${file_changes_raw}"
fi

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
# Format commit_summaries: prefix commit header lines with "- " and
# preserve already-indented body lines (4-space indentation).
while IFS= read -r l; do
  if [[ -z "${l}" ]]; then
    entry_builder+=$'\n'
    continue
  fi
  if [[ "${l:0:4}" == "    " ]]; then
    # body line already indented
    entry_builder+="${l}"$'\n'
  else
    # commit header line
    entry_builder+="- ${l}"$'\n'
  fi
done <<<"${commit_summaries}"
entry_builder+=$'\n'
entry_builder+="Files changed:"$'\n'
entry_builder+="${file_changes}"$'\n'

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
