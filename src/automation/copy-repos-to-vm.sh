#!/usr/bin/env bash

# Script to copy source code to a virtual machine
source_dir=~/Documents/my-repos/my-unicorn
source_dir2=~/Documents/my-repos/auto-penguin-setup
source_dir4=~/Documents/my-repos/linux-system-utils
#TODO: make it env variable instead of name of mnt or something else to make it easy?
# maybe zshrc can handle this easily for me? SECOND_BACKUP_PARTITON=/mnt/backups
shared_folder_dir=/mnt/backups/virt-manager-share/shared-folder

# Copy the source code to the shared folder with rsync
# rsync -avz $source_dir $shared_folder_dir

rsync -avz $source_dir/ $shared_folder_dir/my-unicorn/
rsync -avz $source_dir2/ $shared_folder_dir/auto-penguin-setup/
rsync -avz $source_dir4/ $shared_folder_dir/linux-system-utils/
