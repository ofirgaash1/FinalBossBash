#!/usr/bin/bash

echo

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    # Check if the script is running interactively
    if [[ -t 0 ]]; then
        echo "Running interactively as root."
        interactive=true
    else
        echo "the menu can only run interactively"
        exit 1
    fi
else
    echo "please run this script as root".
    exit 1
fi

processes() {
    echo "number of current processes running in the system: $(($(ps auxh | wc -l) - 1))" # Vlad, I know u said 2
}

echo
echo 'Welcome stranger'
PS3='~Select an option habub: '
options=(
    'view (monitor) the performance of the system'
    'show last 5 backup logs'
    'backup your home directory now (in addition to the regular scheduled backups)'
    'perform cleanup now (in addition to the regular scheduled cleanups)'
    'view current amount of running processes'
    'Quit'
)

select option in "${options[@]}"; do
    case $option in
    "${options[0]}")
        /usr/local/bin/monitor.sh interactive
        ;;
    "${options[1]}")
        /usr/local/bin/backup.sh showLastFiveLogs
        ;;
    "${options[2]}")
        /usr/local/bin/backup.sh manualBackup
        ;;
    "${options[3]}")
        /usr/local/bin/cleanup.sh interactive
        ;;
    "${options[4]}")
        processes
        ;;
    "${options[5]}")
        exit 0
        ;;
    esac
done

echo