#!/usr/bin/bash

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."
else
    echo "please run this script as root"
    exit 1
fi

# $1 is interactive or none

shopt -s globstar

# Current date in seconds since the epoch
current_seconds=$(date +%s)

# Days threshold for file modification, as mentioned by vlad
days_threshold=17

seconds_threshold=$((days_threshold * 86400))
declare -a files_to_delete
total_size=0

# directories mentioned by vlad, separated by spaces
directories="/tmp /var/tmp /var/log"

for directory in $directories; do
    for file in "$directory"/**; do

        # Continue only if it is a file
        if [ -f "$file" ]; then

            # last mod in sec since the epoch.    VLAD - NOTE THAT %Y CHANGES WHEN *DATA* IS MODIFIED, NOT METADATA
            last_modification_seconds=$(stat --format=%Y "$file")

            # last mod since now in days
            last_modification_in_days=$( ((current_seconds - last_modification_seconds) / 86400))

            # Check if the file is older than the threshold
            if [ $last_modification_in_days -ge $days_threshold ]; then
                read -r -a file_info <<<"$(wc -c "$file")"
                files_to_delete+=("${file_info[@]}")
                total_size=$((total_size + ${file_info[0]}))
            fi

        fi
    done
done

# Check total size against threshold of 10 MiB (10485760 bytes)
if [[ $total_size -gt 10485760 && "$1" = "interactive" ]]; then
    echo "Total size of old files to delete is greater than 10 MiB."
    read -p "Are you sure you want to delete these files? (yes/no) " user_input
    if [[ "$user_input" == "yes" ]]; then
        for file_data in "${files_to_delete[@]}"; do
            file_size=${file_data%% *}  # Extract size
            file_path=${file_data#* }  # Extract path
            echo "Deleting $file_path."
            rm "$file_path"
        done
    else
        echo "Deletion aborted by user."
    fi
elif [ "$1" = "scheduled" ]; then
    for file_data in "${files_to_delete[@]}"; do
        file_size=${file_data%% *}  # Extract size
        file_path=${file_data#* }  # Extract path
        echo "Deleting $file_path."
        rm "$file_path"
    done
fi
