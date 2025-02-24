#!/bin/bash

TEMP_ALERT=70
MEM_ALERT=80
DISK_ALERT=80
CPU_LOAD_ALERT=1.0

function decode_throttle_status() {
    local hex_code="$1"

    hex_code=${hex_code#0x}
    local code=$((16#$hex_code))
    local status=""

    (( code & (1 << 0) ))  && status+="⚠️  Under-voltage detected! "
    (( code & (1 << 1) ))  && status+="⚠️  ARM frequency capped! "
    (( code & (1 << 2) ))  && status+="⚠️  Currently throttled! "
    (( code & (1 << 16) )) && status+="⚠️  Under-voltage has occurred! "
    (( code & (1 << 17) )) && status+="⚠️  ARM frequency capping has occurred! "
    (( code & (1 << 18) )) && status+="⚠️  Throttling has occurred! "

    [[ -z "$status" ]] && printf "✅ Normal" || printf "%s" "$status"
}

function show_metrics() {
    clear

    local hostname uptime cpu_temp cpu_load mem_used disk_used throttled_hex throttled_status
    local cpu_temp_val mem_percent disk_percent cpu_load_1 warnings=""

    hostname=$(hostname)
    uptime=$(uptime -p | sed 's/up //')
    cpu_temp=$(vcgencmd measure_temp | cut -d= -f2 | awk '{print $1"°C"}')
    cpu_load=$(awk '{printf "%.1f, %.1f, %.1f", $1, $2, $3}' /proc/loadavg)
    mem_used=$(free -m | awk '/Mem:/ {printf "%.1f%% of %dMB", $3/$2*100, $2}')
    disk_used=$(df -h / | awk '/\// {printf "%s (%s free)", $5, $4}')

    throttled_hex=$(vcgencmd get_throttled | cut -d= -f2)
    throttled_status=$(decode_throttle_status "$throttled_hex")

    cpu_temp_val=$(echo "$cpu_temp" | tr -d -c '0-9.')
    mem_percent=$(echo "$mem_used" | awk '{print $1}' | tr -d '%')
    disk_percent=$(echo "$disk_used" | awk '{print $1}' | tr -d '%')
    cpu_load_1=$(echo "$cpu_load" | cut -d, -f1)

    if (( $(echo "$cpu_temp_val > $TEMP_ALERT" | bc -l) )); then
        warnings+="\e[1;91mHigh CPU Temperature ($cpu_temp)\e[0m\n"
    fi
    if (( $(echo "$mem_percent > $MEM_ALERT" | bc -l) )); then
        warnings+="\e[1;91mHigh Memory Usage ($mem_used)\e[0m\n"
    fi
    if (( $(echo "$disk_percent > $DISK_ALERT" | bc -l) )); then
        warnings+="\e[1;91mHigh Disk Usage ($disk_used)\e[0m\n"
    fi
    if (( $(echo "$cpu_load_1 > $CPU_LOAD_ALERT" | bc -l) )); then
        warnings+="\e[1;91mHigh CPU Load ($cpu_load)\e[0m\n"
    fi

    local separator; separator=$(printf '%*s' 60 | tr ' ' '-')  # Adjust separator length

    read -r -d '' logo <<-"EOF"
	\e[32m   .~~.   .~~.
	\e[32m  '. \ ' ' / .' 
	\e[31m   .~ .~~~..~.
	\e[31m  : .~.'~'.~. :
	\e[31m ~ (   ) (   ) ~
	\e[31m( : '~'.~.'~' : )
	\e[31m ~ .~ (   ) ~. ~
	\e[31m  (  : '~' :  ) 
	\e[31m   '~ .~~~. ~'
	\e[31m       '~'     
	EOF

    read -r -d '' metrics <<EOF
\e[1;94m🖥️  System Status for \e[3;35m$hostname\e[0m
\e[38;5;244m$separator\e[0m
\e[1;93m⏱  Uptime:\e[0m \e[38;5;228m$uptime\e[0m
\e[1;93m🌡️  CPU Temp:\e[0m \e[38;5;203m$cpu_temp\e[0m
\e[38;5;244m$separator\e[0m
\e[1;93m📊 CPU Load (1/5/15m):\e[0m \e[38;5;123m$cpu_load\e[0m
\e[1;93m💾 Memory Usage:\e[0m \e[38;5;156m$mem_used\e[0m
\e[1;93m💽 Disk Usage:\e[0m \e[38;5;219m$disk_used\e[0m
\e[38;5;244m$separator\e[0m
\e[1;93m⚡ Power Status:\e[0m $throttled_status
\e[38;5;244m$separator\e[0m
EOF

    paste <(printf "%b\n" "$logo") <(printf "%b\n" "$metrics") | column -s $'\t' -t

    printf "\e[38;5;244m%s\e[0m\n" " "
    if [[ -n "$warnings" ]]; then
        printf "\e[1;91m⚠️  Warnings:\e[0m\n%s\n" "$warnings"
    else
        printf "\e[1;92mNo warnings.\e[0m\n"
    fi

    printf "\e[1;94m%s\e[0m\n\n" "$(date +'%a %d %b %Y %H:%M:%S %Z')"
}

if [[ $- == *i* ]]; then
    show_metrics
fi
