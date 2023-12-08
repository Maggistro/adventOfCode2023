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

get_next_node () {
    local step=$1
    local node_name=$2
    local current_node_out="${nodes[$node_name]}"

    [[ $debug -ge 3 ]] && echo "Getting next node for $node_name $current_node_out $step" > /dev/tty

    case $step in
        R)
            echo ${current_node_out:3}
            ;;
        L)
            echo ${current_node_out:0:3}
            ;;
    esac
}


for (( i=2; i<${#network[@]}; i++ )); do
    create_node "${network[$i]}" nodes
done

if [[ $debug -ge 3 ]]; then
    echo "Nodes:" > /dev/tty
    for node in "${!nodes[@]}"; do
        value=${nodes[$node]}
        echo "$node = (${value:0:3}, ${value:3})" > /dev/tty
    done
fi

current_node="AAA"
path_step=0
step_counter=0
while [[ $current_node != "ZZZ" ]]; do
    [[ $debug -ge 1 ]] && echo "Current: $current_node ${nodes[$current_node]} with direction: ${path:$path_step:1} at $step_counter" > /dev/tty

    current_node=$(get_next_node ${path:$path_step:1} $current_node)
    if [[ $((path_step + 1)) -lt ${#path} ]]; then
        path_step=$((path_step + 1 ))
    else
        [[ $debug -ge 1 ]] && echo "reset path" > /dev/tty
        path_step=0
    fi

    step_counter=$((step_counter + 1))
done

echo $step_counter