#!/usr/bin/env bash

# Script to copy source code to a virtual machine
source_dir=~/Documents/my-repos/my-unicorn
source_dir2=~/Documents/my-repos/auto-penguin-setup
shared_folder_dir=/mnt/sda2/virt-manager-share/shared-folder

# Copy the source code to the shared folder with rsync
# rsync -avz $source_dir $shared_folder_dir

rsync -avz $source_dir/ $shared_folder_dir/my-unicorn/
rsync -avz $source_dir2/ $shared_folder_dir/auto-penguin-setup/
