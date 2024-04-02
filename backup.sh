#!/bin/bash

# The source path to backup. Can be local or remote.
backup_source="/mnt/data/share/media"

# Where to store the incremental backups
backup_target="/mnt/usb/rsync_backup/file-srv"

# Where to store this backup
current_backup="$backup_target/$(date +%Y-%m-%d_%H:%M:%S)"

# Where to find the most recent backup
last_backup=$(find "$backup_target" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)

# Define global options
global_opts="--archive --verbose --human-readable --delete --info=progress2"

# Define the number of backups to keep before starting to remove the oldest ones
retention_points=10

# Get the number of directories in the backup target
num_folders=$(ls -1 "$backup_target" | wc -l)

# If there are more than the specified number of directories, remove the oldest ones
if [ "$num_folders" -gt "$retention_points" ]; then
    num_folders_to_remove=$((num_folders - retention_points))
    for (( i=1; i<=num_folders_to_remove; i++ )); do
        oldest_folder=$(ls -1 "$backup_target" | sort | head -n 1)
        if [ -n "$oldest_folder" ]; then
            echo "Removing $backup_target/$oldest_folder"
            rm -rf "$backup_target/$oldest_folder"
        fi
    done
fi

# Use the most recent backup as the incremental base if it exists
if [ -d "$last_backup" ]
then
        OPTS="$global_opts --link-dest $last_backup"
else
        OPTS="$global_opts"
fi

# Run the rsync
rsync --delete $OPTS "$backup_source" "$current_backup"
