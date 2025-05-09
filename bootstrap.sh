#!/usr/bin/env bash

clear
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

    echo "0 * * * * $prefix/monitor.sh"
    echo "0 1 4,20 * * $prefix/backup.sh"
    echo "0 1 1 * * $prefix/cleanup.sh"
) | crontab -

echo

if command -v cowsay >/dev/null 2>&1; then
    cowsay "Done. Try to run /usr/local/bin/menu.sh"
else
    echo "Done. I recommend installing cowsay. Now try to run /usr/local/bin/menu.sh"
fi

echo

read -p "Do you want to proceed to the menu? (yes/no) " user_input
if [[ "$user_input" == "yes" ]]; then
    /usr/local/bin/menu.sh
else
    echo "Exiting."
    exit 0
fi

echo