#!/bin/bash

debug=${1:0}
readarray -t sequences < oasis-9/input

get_sub_sequence () {
    local curr_sequence=("$@")
    local sub_sequence=()

    [[ $debug -ge 2 ]] && echo "curr_sequence: ${curr_sequence[*]}" > /dev/tty
    for (( i=1; i<${#curr_sequence[@]}; i++ )); do
        sub_sequence+=($((curr_sequence[i] - curr_sequence[i-1])))
    done

    [[ $debug -ge 2 ]] && echo "sub_sequence: ${sub_sequence[*]}" > /dev/tty
    echo "${sub_sequence[@]}"
}


sum=0
declare -a sequence
for line in "${sequences[@]}"; do
    IFS=' ' read -ra sequence <<< $line

    [[ $debug -ge 1 ]] && echo "Working on ${sequence[*]}" > /dev/tty

    sequence_map=()
    map_counter=0
    sequence_map+=(${sequence[${#sequence[@]} - 1]})
    while [[ "${sequence[*]}" =~ [1-9] ]] && [[ ${#sequence[@]} -gt 1 ]]; do
        map_counter=$((map_counter + 1))
        read -a sequence <<<  $(get_sub_sequence "${sequence[@]}")
        [[ $debug -ge 2 ]] && echo "next sequence: ${sequence[*]}" > /dev/tty
        sequence_map+=(${sequence[${#sequence[@]} - 1]})
    done

    [[ $debug -ge 1 ]] && echo "full map: ${sequence_map[*]}" > /dev/tty

    local_sum=$(IFS=+; echo "$((${sequence_map[*]}))")

    [[ $debug -ge 1 ]] && echo "next value: $local_sum" > /dev/tty

    sum=$((sum + local_sum))
done

echo $sum