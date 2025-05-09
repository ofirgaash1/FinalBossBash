#!/usr/bin/env bash

clear
echo

if command -v cowsay >/dev/null 2>&1; then
    cowsay "let's clean the hell out of your system."
else
    echo 'I recommend installing cowsay for the full experience.'
fi

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."
else
    echo "Please run this script as root"
    exit 1
fi

isInteractive=""
if [[ -t 0 ]]; then
    isInteractive="interactive"
else
    isInteractive="none"
fi

echo


shopt -s globstar

# Days threshold for file modification, as mentioned by vlad
days_threshold=17

seconds_threshold=$((days_threshold * 86400))

# Threshold for total size in bytes (10 MiB)
TEN_MIB=10485760

declare -a files_to_delete
total_size=0

# directories mentioned by vlad, separated by spaces
directories="/tmp /var/tmp /var/log"

for directory in $directories; do
    for file in "$directory"/**; do

        # Continue only if it is a file
        if [ -f "$file" ]; then

            # seconds since the epoch to last mod.    VLAD - NOTE THAT %Y CHANGES WHEN *DATA* IS MODIFIED, NOT METADATA
            last_modification_seconds=$(stat --format=%Y "$file")

            # Current date in seconds since the epoch
            current_seconds=$(date +%s)

            # modified days ago:
            last_modification_in_days=$(( ($current_seconds - $last_modification_seconds) / 86400 ))

            # Check if the file is older than the threshold
            if [ $last_modification_in_days -ge $days_threshold ]; then
                read -r -a file_info <<<"$(wc -c "$file")"
                files_to_delete+=($file)
                total_size=$((total_size + ${file_info[0]}))
            fi
        fi
    done
done

if [[ "$isInteractive" == "interactive" && $total_size -gt $TEN_MIB ]]; then
        echo "Total size of old files to delete is greater than 10 MiB."
        read -p "Are you sure you want to delete these files? (yes/no) " user_input
        if [[ "$user_input" == "yes" ]]; then
            for file in "${files_to_delete[@]}"; do
                echo "Deleting $file."
                rm "$file"
            done
        else
            echo "Deletion aborted by user."
        fi
else
    for file in "${files_to_delete[@]}"; do
        echo "Deleting $file."
        rm "$file"
    done
fi

echo
echo "cleanup done doing its thing"
echo