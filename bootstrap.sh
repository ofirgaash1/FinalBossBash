#!/usr/bin/env bash

prefix="/usr/local/bin"

files=('./menu.sh' './backup.sh' './cleanup.sh' './monitor.sh')
for file in $files[@]; do
    cp $file $prefix
done


# create cron jobs
(
    # print existing crontab
    crontab -l 2>/dev/null

    echo "0 * * * * $prefix/monitor.sh scheduled"
    echo "0 1 4,20 * * $prefix/backup.sh scheduled"
    echo "0 1 1 * * $prefix/cleanup.sh scheduled"
) | crontab -