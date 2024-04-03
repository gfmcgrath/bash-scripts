#!/bin/bash

# Define our options
backup_source="/mnt/data/share/media/"
backup_target="/mnt/usb/rsync_backup/"
global_opts="--archive --verbose --human-readable --delete --info=progress2,stats2"
retention_points=3

#########################################################################################

# Remove any items that have passed the retention period

echo "Checking for backups past retention scope, if they are past scope they will be removed."
# Get the number of directories in the backup target
num_folders=$(ls -1 "$backup_target" | wc -l)
# If there are more than the specified number of directories, remove the oldest ones
if [ "$num_folders" -gt "$retention_points" ]; then
        num_folders_to_remove=$((num_folders - retention_points))
        for (( i=1; i<=num_folders_to_remove; i++ )); do
                oldest_folder=$(find "$backup_target" -mindepth 1 -maxdepth 1 -type d | sort | head -n 1)
                rm -rf "$oldest_folder"
                echo "Removed: $oldest_folder"
        done
fi

# Define backup job parameters
current_backup="$backup_target$(date +%Y-%m-%d_%H:%M:%S)_full"
last_backup=$(find "$backup_target" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)

# Use the most recent backup as the incremental base if it exists
if [ -d "$last_backup" ]; then
        rename=$(find "$backup_target" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 2 | head -n 1)
        mv "$rename" "${rename//_full/}"
        OPTS=""$global_opts" --link-dest "$last_backup""
        echo "Performing incremental backup..."
else
        OPTS=""$global_opts" "--whole-file""
        echo "Performing initial backup job, sending whole-files..."
fi

# Run the rsync
rsync $OPTS "$backup_source" "$current_backup"
