#!/bin/bash

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."

    # Check if the script is running interactively
    if [[ -t 0 ]]; then
        echo "Running interactively."
    else
        rootAndNotInteractive=true;
    fi
else
    echo "Not running as root, script may not have all required privileges."
fi

# rootAndNotInteractive essentially means it's running as crontab operation (?)
if [ rootAndNotInteractive = "true" ]; then

    shopt -s globstar

    # directories mentioned by vlad, seperated by spaces
    directories="/tmp /var/tm /var/log"

    # Current date in seconds since the epoch
    current_seconds=$(date +%s)

    # Days threshold for file modification, as mentioned by vlad
    days_threshold=17

    seconds_threshold=$((days_threshold * 86400))
fi