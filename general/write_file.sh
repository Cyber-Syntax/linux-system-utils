#!/usr/bin/env bash
#This script going to write text to a file until the file reach 1MB

# Constants
file_path="$HOME/.config/my-unicorn/logs/my-unicorn.log"
file_size_limit=$((1024 * 1024)) # 1MB
text_to_write="This is a sample log entry.\n"

while true; do
  echo "$text_to_write" >>"$file_path"

  ## Get the current file size
  file_size=$(stat -c%s "$file_path")

  # Break the loop if the file size exceeds the limit
  if [ "$file_size" -ge "$file_size_limit" ]; then
    echo "File size limit reached. Stopping write operation."
    break
  fi
done

echo "Finished writing to $file_path until it reached 1MB."
