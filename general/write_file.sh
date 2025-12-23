# #!/usr/bin/env bash
# #This script going to write text to a file until the file reach 1MB

# # Constants
# file_path="$HOME/.config/my-unicorn/logs/my-unicorn.log.2"
# file_size_limit=$((1024 * 1024)) # 1MB
# text_to_write="This is a sample log entry.\n"

# while true; do
#   echo "$text_to_write" >>"$file_path"

#   ## Get the current file size
#   file_size=$(stat -c%s "$file_path")

#   # Break the loop if the file size exceeds the limit
#   if [ "$file_size" -ge "$file_size_limit" ]; then
#     echo "File size limit reached. Stopping write operation."
#     break
#   fi
# done

# echo "Finished writing to $file_path until it reached 1MB."

set -o errexit
set -o nounset
set -o pipefail

BASE_DIR="$HOME/.config/my-unicorn/logs"
FILE_COUNT=3
FILE_SIZE_LIMIT=$((1024 * 1024)) # 1MB
TEXT_TO_WRITE="This is a sample log entry.\n"

create_logs() {
  local i
  i=1
  while [[ $i -le $FILE_COUNT ]]; do
    local file_path="$BASE_DIR/my-unicorn.log.$i"
    local start_marker="---log.$i start---\n"
    local end_marker="---log.$i end---\n"

    if ! mkdir -p "$BASE_DIR"; then
      printf "Error: cannot create directory %s\n" "$BASE_DIR" >&2
      return 1
    fi

    # Reserve space for end marker
    local reserved
    reserved=${#end_marker}

    # Compute how many repetitions of TEXT_TO_WRITE fit
    local block
    block=$(printf "%s" "$TEXT_TO_WRITE")
    local block_size
    block_size=${#block}
    local max_blocks
    max_blocks=$(((FILE_SIZE_LIMIT - reserved - ${#start_marker}) / block_size))

    if [[ $max_blocks -le 0 ]]; then
      printf "Error: file size limit too small for content\n" >&2
      return 1
    fi

    {
      printf "%s" "$start_marker"
      yes "$TEXT_TO_WRITE" | head -c $((max_blocks * block_size))
      printf "%s" "$end_marker"
    } >"$file_path"

    local actual_size
    actual_size=$(stat -c%s "$file_path")
    if [[ $actual_size -gt $FILE_SIZE_LIMIT ]]; then
      printf "Error: file %s exceeded size limit\n" "$file_path" >&2
      return 1
    fi

    printf "Wrote %s up to %d bytes\n" "$file_path" "$FILE_SIZE_LIMIT"
    i=$((i + 1))
  done
}

main() {
  if ! create_logs; then
    printf "Log creation failed\n" >&2
    return 1
  fi
}

main "$@"
