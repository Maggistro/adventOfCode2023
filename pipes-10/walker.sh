#!/bin/bash
TOP=2
RIGHT=3
BOT=5
LEFT=7

debug=${1:0}
readarray -t raw < pipes-10/small_encirclement
declare -a grid=()
line_length=${#raw[0]}

get_next_position () {
    local position=$1
    local direction=$2

    [[ $debug -ge 2 ]] && echo "from at $position with $direction" > /dev/tty

    # set next position + direction to incoming
    case $direction in
        "$TOP")
            position=$((position - line_length))
            direction=$BOT
            ;;
        "$RIGHT")
            position=$((position + 1))
            direction=$LEFT
            ;;
        "$BOT")
            position=$((position + line_length))
            direction=$TOP
            ;;
        "$LEFT")
            position=$((position - 1))
            direction=$RIGHT
            ;;
    esac

    [[ $debug -ge 2 ]] && echo "get_next_position: $position $((grid[position] / direction))" > /dev/tty
    echo "$position $((grid[position] / direction))"
}

get_start_pipes () {
    local position=$1
    local -n output_position=$2
    local -n output_direction=$3

    [[ $debug -ge 1 ]] && echo "get_start_pipes at $position" > /dev/tty

    # check top
    if [[ $((grid[position - line_length] % BOT)) -eq 0 ]]; then
        [[ debug -ge 1 ]] && echo "found top" > /dev/tty
        output_position+=($((position - line_length)))
        output_direction+=($((grid[position - line_length] / BOT)))
    fi

    # check right
    if [[ $((grid[position + 1] % LEFT)) -eq 0 ]]; then
        [[ debug -ge 1 ]] && echo "found right" > /dev/tty
        output_position+=($((position + 1)))
        output_direction+=($((grid[position + 1] / LEFT)))
    fi

    # check bottom
    if [[ $((grid[position + line_length] % TOP)) -eq 0 ]]; then
        [[ debug -ge 1 ]] && echo "found bot" > /dev/tty
        output_position+=($((position + line_length)))
        output_direction+=($((grid[position + line_length] / TOP)))
    fi

    # check left
    if [[ $((grid[position - 1] % RIGHT)) -eq 0 ]]; then
        [[ debug -ge 1 ]] && echo "found left" > /dev/tty
        output_position+=($((position - 1)))
        output_direction+=($((grid[position - 1] / RIGHT)))
    fi

    [[ $debug -ge 1 ]] && echo "get_start_pipes: ${output_position[*]} with ${output_direction[*]}" > /dev/tty
}

transform_value () {
    value=$1

    case $value in
        'L')
            echo "6"
            ;;
        '|')
            echo "10"
            ;;
        'J')
            echo "14"
            ;;
        'F')
            echo "15"
            ;;
        '-')
            echo "21"
            ;;
        '7')
            echo "35"
            ;;
        '.')
            echo "1"
            ;;
        *)
            echo "$value"
            ;;
    esac
}

# transform grid and find start
start_position=-1
for line in "${raw[@]}"; do
    for (( character=0; character<line_length; character++ )); do
        new_value="$(transform_value "${line:$character:1}")"
        grid+=("$new_value")
        if [[ $new_value == "S" ]]; then
            start_position=$((${#grid[@]} - 1))
        fi
    done
done

# find both starts
declare -a current_positions
declare -a outgoing_direction
get_start_pipes $start_position current_positions outgoing_direction

first_walker=("${current_positions[0]}" "${outgoing_direction[0]}")
second_walker=("${current_positions[1]}" "${outgoing_direction[1]}")

# run while not equal
counter=1
while [[ "${first_walker[0]}" -ne "${second_walker[0]}" ]]; do
    first_walker=($(get_next_position "${first_walker[0]}" "${first_walker[1]}"))
    second_walker=($(get_next_position "${second_walker[0]}" "${second_walker[1]}"))
    counter=$((counter + 1))
done

echo $counter
