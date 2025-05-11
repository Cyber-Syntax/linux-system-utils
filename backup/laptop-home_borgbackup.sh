#!/bin/bash -e
# Extract command
# sudo borg extract --progress --list /mnt/backups/borgbackup/doc-repo::doc-27-02-2024

export BORG_UKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

REPOSITORY_home='/backup/home-laptop'

echo "Starting backup"
# home
sudo borg create --list --filter=AME --progress --stats --exclude-caches --show-rc \
  --exclude /home/*/Documents/backup-for-cloud/*tar.xz \
  --exclude /home/*/.cache/ \
  --exclude /home/*Downloads/ \
  --exclude /**.snapshots/ \
  --exclude /home/*/Trash/ \
  --exclude /home/*thumbnails/ \
  --exclude /home/*mozilla/firefox/*.default-release/storage/default/* \
  --exclude /home/*/.npm/_cacache/ \
  --exclude /home/*/node_modules/ \
  --exclude /home/*/bower_components/ \
  --exclude /home/*/.config/Code/CachedData/ \
  --exclude /home/*/.tox/ \
  --exclude /home/*/.venv/ \
  $REPOSITORY_home::'{now:home-%d-%m-%Y}' \
  /home/*/.config/qtile/ \
  /home/*/.config/FreeTube/
#/home/*/.local \

echo "Backup of home directory complete"

echo "Pruning old home backups"

# --show-rc: if return 0 code, then it's successful
sudo borg prune -v $REPOSITORY_home --list --stats --show-rc \
  --keep-daily=7 \
  --keep-weekly=4 \
  --keep-monthly=2

sudo borg check $REPOSITORY_home
# after check
echo "Check complete"

# compact the repository to free up the space
sudo borg compact $REPOSITORY_home

echo "Compaction complete"
# make sure to sync
sync

# if return = 'rc 0' then it's successful
if [ $? -eq 0 ]; then
  echo "Backup and prune complete!"
else
  echo "Backup and prune failed!"
fi
