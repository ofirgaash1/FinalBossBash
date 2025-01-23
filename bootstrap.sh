#!/usr/bin/env bash

echo

prefix="/usr/local/bin"

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."
else
    echo "please run this script as root."
    exit 1
fi

echo

files=('./menu.sh' './backup.sh' './cleanup.sh' './monitor.sh')
for file in "${files[@]}"; do
    echo "copying $file to $prefix and granting 777 permissions"
    cp $file $prefix
    chmod +x "$prefix/$(basename "$file")"
done

# create cron jobs
(
    # print existing crontab
    crontab -l 2>/dev/null

    echo "0 * * * * $prefix/monitor.sh scheduled"
    echo "0 1 4,20 * * $prefix/backup.sh scheduled"
    echo "0 1 1 * * $prefix/cleanup.sh scheduled"
) | crontab -

echo
if command -v cowsay >/dev/null 2>&1; then
    cowsay "done. try to run /usr/local/bin/menu.sh"
else
    echo "done. i recommend installing cowsay. now try to run /usr/local/bin/menu.sh"
fi
echo