#!/bin/bash

calculate_distances () {
    local time=$1
    local distance=$2
    local winning_count=0

    echo "$time $distance" > /dev/tty

    for (( i=0; i<time; i++ )); do
        if [[ $(((time - i) * i)) -gt $distance ]]; then
            winning_count=$((winning_count + 1))
        fi
    done

    echo $winning_count > /dev/tty

    echo $winning_count
}

readarray -t race_data < race-6/input
IFS=':' read -ra time_line <<< ${race_data[0]}
IFS=':' read -ra distance_line <<< ${race_data[1]}

total_record_breaks=$(calculate_distances $(sed "s/ //g" <<< ${time_line[1]}) $(sed "s/ //g" <<< ${distance_line[1]}))

echo $total_record_breaks
