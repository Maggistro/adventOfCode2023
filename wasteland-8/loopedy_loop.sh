#!/bin/bash

# input and globals
debug=${1:0}
readarray -t network < wasteland-8/input
read -ra path <<< "${network[0]}"
typeset -A nodes

create_node () {
    local input=$1
    local -n node_list=$2

    IFS='=' read -ra node <<< $input
    input=${node[1]}
    IFS=',' read -ra node_out <<< ${input:2:-1}
    left=${node_out[0]}
    right=${node_out[1]}
    index=${node[0]}

    [[ $debug -ge 2 ]] && echo "Creating node ${index:0:-1} $left${right:1}" > /dev/tty
    node_list["${index:0:-1}"]="${left[0]}${right:1}"
}

build_loop () {
    local node_name=$1
    local -n node_list=$2
    local path=$3
    path_length=$((${#path} - 1))

    paths=()

    [[ $debug -ge 1 ]] && echo "Building loop for $node_name" > /dev/tty


    found_positions=()
    step_counter=0
    while :; do
        [[ $debug -ge 3 ]] && echo "Current: $node_name at $step_counter" > /dev/tty

        if [[ ${node_name:2:1} == "Z" ]]; then
            echo "Z found for $node_name at $step_counter" > /dev/tty
            found_positions+=($step_counter)
        fi

        if [[ ${paths["$node_name$path_step"]+set} ]]; then
            echo "Loop found for $node_name at $step_counter" > /dev/tty
            break
        fi
        paths["$node_name$path_step"]=$step_counter

        current_node_out="${nodes[$node_name]}"
        node_name=$([ "${path:$path_step:1}" == "R" ] && echo "${current_node_out:3}" || echo "${current_node_out:0:3}")

        if [[ $path_step -lt $path_length ]]; then
            path_step=$((path_step + 1 ))
        else
            [[ $debug -ge 2 ]] && echo "reset path" > /dev/tty
            path_step=0
        fi
        step_counter=$((step_counter + 1))
    done

    echo "paths ${#paths[@]}" > /dev/tty
    echo "Z positions ${found_positions[*]}" > /dev/tty
    echo "${found_positions[@]}"
}

declare -A paths
for (( i=2; i<${#network[@]}; i++ )); do
    create_node "${network[$i]}" nodes paths
done

current_node_list=()
for node in "${!nodes[@]}"; do
    if [[ ${node:2:1} == "A" ]]; then
        current_node_list+=($node)
    fi
done

[[ $debug -ge 1 ]] && echo "Starting nodes: ${current_node_list[*]}" > /dev/tty

loops=()
for (( i=0; i<${#current_node_list[@]}; i++ )); do
    loops+=("$(build_loop "${current_node_list[$i]}" nodes "$path")")
done

echo "${loops[@]}"