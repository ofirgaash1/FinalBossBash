#!/usr/bin/bash

# $1 is interactive or none

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."
else
    echo "please run this script as root."
    exit 1
fi

# sed: stream editor
# 2p: second line
# free -b gives ram stats with a nice readable format
# we save this to an array (IFS of spaces)
read -r -a RAMstats <<<"$(sed -n 2p <<<"$(free -b)")"

total_memory=${RAMstats[1]}
used_memory=${RAMstats[2]}

# no floats in bash so let's escape to python...
MEMprecents=$(python3 -c "print(f'{${used_memory} * 100 / ${total_memory} :.2f}')")

# same principle
# sed: stream editor
# 3p: third line
# vmstat gives many stats including cpu with a nice readable format
# we save this to an array (IFS of spaces)
read -r -a cpu_usage_a <<<"$(vmstat | sed -n 3p)"
idle_time="${cpu_usage_a[-3]}"
cpu_usage=$((100 - $idle_time))

for interface in /sys/class/net/*; do
    if [[ -d $interface/device ]]; then
        tx=$(<"$interface/statistics/tx_bytes")
        rx=$(<"$interface/statistics/rx_bytes")
    fi
done

lineForLog="[$(date)] $cpu_usage $MEMprecents% $tx $rx"

# -s option returns true when file exists and not empty
logExists="false"
if [[ -s "/var/log/monitor.log" ]]; then
    logExists="true"
fi

if [ $1 = "interactive" && $logExists = "true" ]; then

    read -r -a last_log_entry <<<"$(tail -1 "/var/log/monitor.log" | cut -d ']' -f 2)"

    difCPU=$(($cpu_usage - ${last_log_entry[0]}))

    if [ "$difCPU" -lt 0 ]; then
        trendCPU="fall"
    else
        trendCPU="rise"
    fi

    if [ "$difMEM" -lt 0 ]; then
        trendMEM="fall"
    else
        trendMEM="rise"
    fi
    echo "Current system metrics:"
    echo "CPU usage: $cpu_usage% , and the trend is a $trendCPU"
    echo "Memory usage: current – $MEMprecents%, and the trend is a $trendMEM"
    echo "Tx/Rx bytes: $tx/$rx"
else
    echo "$lineForLog" >>/var/log/monitor.log
    echo "$lineForLog"
fi