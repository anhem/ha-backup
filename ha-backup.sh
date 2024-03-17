#!/bin/bash

count_remote_tar_files() {
    local server="$1"
    local directory="$2"
    local count

    count=$(ssh "$server" find "$directory" -type f -name '*.tar' | wc -l)
    echo "$count"
}

count_local_tar_files() {
    local directory="$1"
    local count

    count=$(find "$directory" -type f -name '*.tar' | wc -l)
    echo "$count"
}

delete_remote_old_tar_files() {
    local server="$1"
    local directory="$2"
    local threshold="$3"
    local deleted_files

    echo "Deleting older .tar files on $server:$directory..."
    deleted_files=$(ssh "$server" "find" \""$directory"\" "-type f -name '*.tar' -mtime +$threshold -exec rm -fv {} \;")
    echo "Deleted .tar files on $server:$directory:"
    echo "$deleted_files"
}

delete_local_old_tar_files() {
    local directory="$1"
    local threshold="$2"
    local deleted_files

    echo "Deleting older .tar files in $directory..."
    deleted_files=$(find "$directory" -type f -name '*.tar' -mtime +"$threshold" -exec rm -fv {} \;)
    echo "Deleted .tar files in $directory:"
    echo "$deleted_files"
}

do_backup_and_delete() {
    local server="$1"
    local source_dir="$2"
    local backup_dir="$3"

    latest_backup_file=$(ssh "$server" "ls -t" "$source_dir" "| head -1")
    echo "Downloading $latest_backup_file from $server:$source_dir to $backup_dir"
    if (scp "$server:$source_dir$latest_backup_file" "$backup_dir"); then
        echo "Backup file downloaded successfully."

        if [ "$(count_remote_tar_files "$server" "$source_dir")" -gt 1 ]; then
            delete_remote_old_tar_files "$server" "$source_dir" 7
        else
            echo "Only one .tar file left on $server:$source_dir. Skipping deletion."
        fi

        if [ "$(count_local_tar_files "$backup_dir")" -gt 1 ]; then
            delete_local_old_tar_files "$backup_dir" 30
        else
            echo "Only one .tar file left in $backup_dir. Skipping deletion."
        fi
    else
        echo "Failed to download backup file. Exiting..."
        exit 1
    fi

}

if [ $# -ne 3 ]; then
    echo "Usage: $0 <user@server> <source directory> <backup directory>"
    exit 1
fi

do_backup_and_delete "$1" "${2%/}/" "${3%/}/"