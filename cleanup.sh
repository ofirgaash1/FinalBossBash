#!/bin/bash

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."

    # Check if the script is running interactively
    if [[ -t 0 ]]; then
        echo "Running interactively."
    else
        echo "Running from crontab or another non-interactive source."
    fi
else
    echo "Not running as root, script may not have all required privileges."
fi
