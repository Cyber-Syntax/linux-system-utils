# #!/bin/bash

# sudo rsync -avz --progress \
#   --exclude-from "rsync-exclude.txt" \
#   /home/developer/ laptop:/home/

# one time rsync from local to remote
sudo rsync -avzP \
  --exclude='/home/developer/Downloads/' \
  --exclude='Downloads/' \
  --exclude='~/Downloads/' \
  --exclude='/home/developer/.cache/' \
  --exclude='.cache/' \
  --exclude='/home/developer/tmp/' \
  --exclude="~/tmp/" \
  --exclude='/home/developer/.local/share/Trash/' \
  --exclude='.local/share/Trash/' \
  --exclude='~/.local/share/Trash/' \
  --exclude='/home/developer/Documents/backup-for-cloud/' \
  --exclude='Documents/backup-for-cloud/' \
  --exclude='~/Documents/backup-for-cloud/' \
  --exclude='/home/developer/Documents/backup-for-cloud/*' \
  /home/developer laptop:/home/
