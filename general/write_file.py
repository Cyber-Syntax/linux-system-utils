"""Write multiple files with specific size limits and markers."""

import os

# Config
base_dir = os.path.expanduser("~/.config/my-unicorn/logs")
os.makedirs(base_dir, exist_ok=True)

file_count = 3
file_size_limit = 1024 * 1024 * 10  # 10 MB
text_to_write = b"This is a sample log entry.\n"

for i in range(1, file_count + 1):
    file_path = os.path.join(base_dir, f"my-unicorn.log.{i}")
    with open(file_path, "wb") as f:
        start_marker = f"======log.{i} start=====\n".encode()
        end_marker = f"=====log.{i} end=====\n".encode()
        f.write(start_marker)

        # Fill file until reaching size limit - reserve for end marker
        while f.tell() + len(end_marker) < file_size_limit:
            f.write(text_to_write)

        f.write(end_marker)

    print(f"Wrote {file_path} up to {file_size_limit} bytes")
