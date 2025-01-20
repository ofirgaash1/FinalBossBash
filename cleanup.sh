#!/bin/bash

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."

    # Check if the script is running interactively
    if [[ -t 0 ]]; then
        echo "Running interactively."
    else
        rootAndNotInteractive=true
    fi
else
    echo "Not running as root, script may not have all required privileges."
fi

rootAndNotInteractive=true
# rootAndNotInteractive essentially means it's running as crontab operation (?)
if [ $rootAndNotInteractive = "true" ]; then
    shopt -s globstar

    # directories mentioned by vlad, seperated by spaces
    directories="/tmp /var/tm /var/log"

    # Current date in seconds since the epoch
    current_seconds=$(date +%s)

    # Days threshold for file modification, as mentioned by vlad
    days_threshold=17

    seconds_threshold=$((days_threshold * 86400))

    for directory in $directories; do
        for file in "$directory"/**; do

            # Continue only if it is a file
            if [ -f "$file" ]; then

                # last mod in sec since the epoch
                last_modification_seconds=$(stat --format=%Y "$file")

                # last mod since now in days
                last_modification_in_days=$(((current_seconds - last_modification_seconds) / 86400))

                # Check if the file is older than the threshold
                if [ $last_modification_in_days -ge $days_threshold ]; then
                    echo "Deleting $file modified $last_modification_in_days days ago."
                    rm "$file"
                fi
                
            fi
        done
    done
fi