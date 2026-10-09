#!/usr/bin/env bash
#
# USAGE: cd tests && ./generate_release.sh

set -euo pipefail

readonly DUMM_ENV_FILE="/tmp/mock_github_output.env"
readonly OUTPUT_MD="release.md"

# mock environment
export GITHUB_OUTPUT="$DUMM_ENV_FILE"
>"$GITHUB_OUTPUT" # clear the file if it is exist

echo ":: Running parsechangelog.sh..."
# pass the actual repo changelog. defaults to changelog.md
../src/parsechangelog.sh "${1:-../CHANGELOG.md}"

echo ":: Parsing github actions output format..."

# extract just the version to display in terminal
VERSION=$(grep "^version=" "$GITHUB_OUTPUT" | cut -d'=' -f2 || echo "Unkown")
IS_UNRELEASED=$(grep "^is_unreleased=" "$GITHUB_OUTPUT" | cut -d'=' -f2 || echo "false")

if [[ "$IS_UNRELEASED" == "true" ]]; then
  echo ":: Version is Unreleased. No release.md wil be generated"
  exit 0
fi

# extract the multiline notes
# this awk scripts look for the `notes<<DELIMETER` syntax,
# extracts the delimeter, captures everything in between,
# and writes it to release.md
awk '
  # When we find the start of the multiline string
  /^notes<</ {
    # Extract the dynamic EOF string (everything after "notes<<")
    delimiter = substr($0, 8);
    capture = 1;
    next;
  }

  # When we hit the dynamic EOF string, stop capturing
  capture == 1 && $0 == delimiter {
    capture = 0;
    next;
  }

  # If we are capturing, print the line
  capture == 1 {
    print;
  }
' "$GITHUB_OUTPUT" >"$OUTPUT_MD"

echo ":: Success! Version [$VERSION] notes extracted."
echo ":: View your output below or open $OUTPUT_MD:"
echo "---------------------------------------------------"
cat "$OUTPUT_MD"
echo "---------------------------------------------------"
