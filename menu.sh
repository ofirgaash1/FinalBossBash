echo 'Welcome stranger'
PS3='~Select an option habub: '
options=(
    'view (monitor) the performance of the system' 
    'show last 5 backup logs' 
    'backup your home directory now (in addition to the regular scheduled backups)' 
    'perform cleanup now (in addition to the regular scheduled cleanups)' 
    'view current amount of running proccesses'
    'Quit'
)

select option in "${options[@]}"; do
    case $option in
    "${options[0]}")
        /usr/local/bin/monitor.sh
        ;;
    "${options[1]}")
        /usr/local/bin/backup.sh showLastFiveLogs
        ;;
    "${options[2]}")
        /usr/local/bin/backup.sh manualBackup
        ;;
    "${options[3]}")
        /usr/local/bin/cleanup.sh
        ;;
    "${options[4]}")
        proccesses()  ############################################ TODO
        ;;
    "${options[5]}")
        exit 0
        ;;
    esac
done
