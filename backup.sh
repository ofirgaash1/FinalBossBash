#!/usr/bin/env bash

clear
echo

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."
else
    echo "Please run this script as root."
    exit 1
fi

isInteractive=""
if [[ -t 0 ]]; then
    isInteractive="interactive"
else
    isInteractive="none"
fi

if command -v cowsay >/dev/null 2>&1; then
    cowsay "let's back-up the hell out of your system."
else
    echo 'I recommend installing cowsay for the full experience.'
fi

mkdir -p /opt/sysmonitor/backups/

for file in /opt/sysmonitor/backups/*; do

    # Continue only if it is a file
    if [ -f "$file" ]; then

        # last mod in sec since the epoch.    VLAD - NOTE THAT %Y CHANGES WHEN *DATA* IS MODIFIED, NOT METADATA
        last_modification_seconds=$(stat --format=%Y "$file")

        current_seconds=$(date +%s)

        # last mod since now in days
        last_modification_in_days=$(((current_seconds - last_modification_seconds) / 86400))

        # Check if the file is older than the threshold
        if [ $last_modification_in_days -ge 7 ]; then
            rm "$file"
        fi

    fi
done

backup() {
    TARGET='/home'

    # Read total size in bytes of a directory into array
    read -r -a dir_size_in_bytes_a <<<"$(du -sb "$TARGET")"

    dir_size_in_bytes="${dir_size_in_bytes_a[0]}"

    echo "$TARGET directory is overall $dir_size_in_bytes bytes"

    # tail command gets lines from the end of the file
    available_free_space_in_bytes="$(df -B 1 --output=avail / | tail -1)"
    echo "You have total $available_free_space_in_bytes free bytes on /"

    if [ "$dir_size_in_bytes" -gt "$available_free_space_in_bytes" ]; then
        echo "backup.sh: not enough space for a backup. $(date)" >>/var/log/backup.log
        echo "backup.sh: not enough space for a backup. $(date) (logged)"
        echo
        exit 1
    fi

    format="+%Y_%m_%d_%H_%M_%S_home_backup.tar.gz"
    date_formatted_string="$(date +"$format")"

    if ! tar -czf "/opt/sysmonitor/backups/$date_formatted_string" -C "$TARGET" . --ignore-failed-read 2>>/var/log/backup.log; then
        echo "backup.sh: error occurred during backup. $(date)" >>/var/log/backup.log
        echo "backup.sh: error occurred during backup. $(date)"
        exit 1
    fi
    echo "backup.sh: home backed-up successfully. $(date)"
    echo "backup.sh: home backed-up successfully. $(date)" >>/var/log/backup.log
}

if [ "$isInteractive" = "interactive" ]; then

    if [ "$1" = "showLastFiveLogs" ]; then
        file_name='/var/log/backup.log'

        # -s option returns true when file exists and not empty
        if [[ ! -s "$file_name" ]]; then
            echo "$file_name doesn't exist or is empty because no backups have been made yet."
        else
            tail -5 "$file_name"
        fi
    
    elif [ "$1" = "manualBackup" ]; then
        backup
    fi
else
    backup
fi

echo
