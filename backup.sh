#!/usr/bin/bash

manualBackupORshowLastFiveLogs=$1

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

if [ $manualBackupORshowLastFiveLogs = "manualBackup" || $notInteractive = "true"]; then

    TARGET='/home'

    # Read total size in bytes of a directory into array
    read -r -a dir_size_in_bytes_a <<<"$(du -sb "$TARGET")"

    dir_size_in_bytes="${dir_size_in_bytes_a[0]}"

    echo "$TARGET directory is overall $dir_size_in_bytes bytes"

    available_free_space_in_bytes=$(df --output=avail / | tail -1)

    echo "You have total $available_free_space_in_bytes free bytes on /"

    if [ $dir_size_in_bytes -lt $available_free_space_in_bytes ]; then
        "backup.sh: no enough space for a backup. $(date)" >>/var/log/backup.log
        exit 1
    fi

    format="+%Y_%m_%d_%H_%M_%S_home_backup.tar.gzip"
    date_formated_string="$(date "$format")"

    tar czf "/opt/sysmonitor/backups/$date_formated_string" --ignore-failed-read $TARGET 2>/dev/null 2>&1

    "backup.sh: home backed-up successfully. $(date)" >>/var/log/backup.log

elif [ "$manualBackupORshowLastFiveLogs" = "showLastFiveLogs" ]; then

    file_name='/var/log/backup.log'

    # -s option returns true when file exists and not empty
    if [[ ! -s "$file_name" ]]; then
        echo "$file_name doesn't exist or is empty"
    else
        # tail command gets lines from the end of the file
        tail -5 "$file_name"
    fi
fi
