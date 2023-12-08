#!/bin/bash

# input and globals
create_node () {
    local input=$1
    local -n node_list=$2

    IFS='=' read -ra node <<< $input
    input=${node[1]}
    IFS=',' read -ra node_out <<< ${input:2:-1}
    left=${node_out[0]}
    right=${node_out[1]}
    index=${node[0]}

    node_list["${index:0:-1}"]="${left[0]}${right:1}"
}

next_step () {
    local index=$1
    local log_file="log_$index.log"
    rm -f "$log_file"
    local lock_file="/run/shm/semaphore/$index"

    readarray -t network < wasteland-8/input
    path="${network[0]}"
    read -ra current_nodes <<< "$(cat /run/shm/current_nodes)"

    local semaphore=()
    rm -f "$lock_file"
    echo "0" > $lock_file

    local my_node=${current_nodes[$index]}

    create_node () {
        local input=$1
        local -n node_list=$2

        IFS='=' read -ra node <<< $input
        input=${node[1]}
        IFS=',' read -ra node_out <<< ${input:2:-1}
        left=${node_out[0]}
        right=${node_out[1]}
        pos=${node[0]}

        node_list["${pos:0:-1}"]="${left[0]}${right:1}"
    }

    declare -A nodes
    for (( i=2; i<${#network[@]}; i++ )); do
        create_node "${network[$i]}" nodes
    done


    echo "$my_node $path "${current_nodes[@]}" "${nodes[@]}" "$(cat $lock_file)" \n" >> $log_file

    local continue_calculation=0
    local match_found=1
    local step_counter=1
    local path_step=0
    local path_length=$((${#path} - 1))
    while :; do
        continue_calculation=0
        current_node_out="${nodes[$my_node]}"
        # echo "$step_counter: $my_node $current_node_out ${path:$path_step:1}" >> $log_file
        next_node=$([ "${path:$path_step:1}" == "R" ] && echo "${current_node_out:3}" || echo "${current_node_out:0:3}")
        my_node=$next_node


        # check local end found
        if [[ ${next_node:2:1} == "Z" ]]; then
            match_found=1
            # save + reload semaphore (lock collision?)
            echo "found one $step_counter" >> $log_file

            # exec 100>/var/lock/semaphore.lock
            # flock -x 100
            echo $step_counter > $lock_file
            semaphore=($(cat $(ls "/run/shm/semaphore/"*)))
            # exec 100>&-

            while [[ $continue_calculation -eq 0 ]]; do
                for shared_steps in "${semaphore[@]}"; do
                    if [[ $shared_steps -gt $step_counter ]]; then
                        continue_calculation=1
                    fi

                    if [[ $shared_steps -ne $step_counter ]]; then
                        match_found=0
                    fi
                done

                if [[ $match_found -eq 1 ]]; then
                    break 2;
                fi

                semaphore=($(cat $(ls "/run/shm/semaphore/"*)))
                # echo "reload and wait ${semaphore[*]}" >> $log_file
                sleep 0.1s
            done

            # echo "continue search" >> $log_file
        fi

        # continue to next end
        if [[ $path_step -lt $path_length ]]; then
            path_step=$((path_step + 1 ))
        else
            # [[ $debug -ge 1 ]] && echo "reset path" > /dev/tty
            path_step=0
        fi
        step_counter=$((step_counter + 1))
    done

    echo "$step_counter" > "result_$index"
}

debug=${1:0}
readarray -t network < wasteland-8/input
read -ra path <<< "${network[0]}"

declare -A nodes
for (( i=2; i<${#network[@]}; i++ )); do
    create_node "${network[$i]}" nodes
done

current_nodes=()
for node in "${!nodes[@]}"; do
    if [[ ${node:2:1} == "A" ]]; then
        current_nodes+=($node)
    fi
done

semaphore=()
for (( sem=0; sem<${#current_nodes[@]}; sem++ )); do
    semaphore+=(0)
done
echo "${current_nodes[@]}" > /run/shm/current_nodes

[[ $debug -ge 1 ]] && echo "Starting nodes: ${current_nodes[*]}" > /dev/tty

# [[ $debug -ge 1 ]] && echo "Current: ${current_node_list[*]} at $step_counter" > /dev/tty

export -f next_step
parallel next_step ::: ${!current_nodes[@]}

echo $step_counter