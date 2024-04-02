#!/bin/bash

# Incremental Rotating Backup Using rsync

# Sources
# https://digitalis.io/blog/linux/incremental-backups-with-rsync-and-hard-links/
# https://rsync.samba.org/examples.html
# https://www.admin-magazine.com/Articles/Using-rsync-for-Backups/(offset)/2
# ChatGPT

set -e

# Backup source
backup_source="/home/garym/backup_test/source"

# Backup destination
backup_dest="/home/garym/backup_test/dest"

# rsync options
global_opts="--archive --verbose --human-readable --delete"

# Define the number of folders to keep before starting to remove the oldest ones
num_folders_to_keep=3

# Ensure backup_dest exists
if [ ! -d $backup_dest ]; then
    echo "Backup destination $backup_dest does not exist!"
    exit 1
fi

# Get the number of folders
num_folders=$(ls -1 $backup_dest | wc -l)

# If there are more than the specified number of folders, remove the oldest ones
if [ $num_folders -gt $num_folders_to_keep ]; then
    num_folders_to_remove=$((num_folders - num_folders_to_keep))
    for (( i=1; i<=num_folders_to_remove; i++ )); do
        oldest_folder=$(ls -1 $backup_dest | sort | head -n 1)
        if [ -n $oldest_folder ]; then
            rm -rf $backup_dest/$oldest_folder
        fi
    done
fi

# Get the newest folder
#newest_folder=$(ls -1 $backup_dest | sort -r | head -n 1)
newest_folder=$(ls -1 $backup_dest 2>/dev/null | sort -r | head -n 1)

# Run rsync
if [ -d "$newest_folder" ]; then
    opts="$global_opts --link-dest $newest_folder"
else
    opts="$global_opts"
fi

rsync $opts $backup_source $backup_dest/$(date +%Y-%m-%d)_backup
