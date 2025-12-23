# #!/bin/bash

# one time rsync from laptop to desktop via ssh
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
  /home/developer developer@desktop:/home/developer/Documents/backup-for-cloud/laptop/
