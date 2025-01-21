#!/usr/bin/bash

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."

    # Check if the script is running interactively
    if [[ -t 0 ]]; then
        echo "Running interactively."
        interactive=true
    else
        notInteractive=true
    fi
else
    echo "please run this script as root".
    exit 1
fi

if [ $notInteractive = "true" ]; then
    
fi