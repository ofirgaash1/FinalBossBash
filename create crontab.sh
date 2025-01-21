#!/usr/bin/env bash

prefix="/usr/local/bin"
# create cron jobs
(
    # delete previous user's crobtab to prevent conflicts
    crontab -r

    # print existing cronta
    crontab -l 2>/dev/null
    
    echo "0 * * * * $prefix/monitor.sh"
    echo "0 1 4,20 * * $prefix/backup.sh"
    echo "0 1 1 * * $prefix/cleanup.sh"
) | crontab -