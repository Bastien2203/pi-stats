TEMP_ALERT=70
MEM_ALERT=80
DISK_ALERT=80
CPU_LOAD_ALERT=1.0

uptime=$(cut -d' ' -f1 /proc/uptime)
cpu_temp=$(vcgencmd measure_temp | cut -d= -f2 | cut -d"'" -f1)
cpu_load=$(cut -d' ' -f1 /proc/loadavg)
mem_used=$(awk '/MemTotal/ {total=$2} /MemAvailable/ {printf "%.0f", (total-$2)/total*100}' /proc/meminfo)
disk_used=$(df / | awk 'NR==2 {gsub("%", ""); print $5}')

function notify() {

    echo "$1"
}

if (( $(echo "$cpu_temp > $TEMP_ALERT" | bc -l) )); then
    notify "High CPU Temperature ($cpu_temp°C)"
fi

if (( mem_used > MEM_ALERT )); then
    notify "High Memory Usage ($mem_used%)"
fi

if (( disk_used > DISK_ALERT )); then
    notify "High Disk Usage ($disk_used%)"
fi

if (( $(echo "$cpu_load > $CPU_LOAD_ALERT" | bc -l) )); then
    notify "High CPU Load ($cpu_load)"
fi
