#!/bin/bash
TOP=2
RIGHT=3
BOT=5
LEFT=7

debug=${1:0}
readarray -t raw < pipes-10/input
declare -a grid=()
declare -a full_path=()
declare -A path_index=()
line_length=${#raw[0]}

get_left_right () {
    local curr_in=$1
    local value=$2
    local next_out=$((value / direction))

    [[ $debug -ge 2 ]] && echo "get_left_right: $curr_in $value $next_out" > /dev/tty

    case $curr_in in
        "$TOP")
            if (( next_out == LEFT )); then
                echo "-1"
            elif (( next_out == RIGHT )); then
                echo "1"
            else
                echo "0"
            fi
            ;;
        "$RIGHT")
            if (( next_out == BOT )); then
                echo "-1"
            elif (( next_out == TOP )); then
                echo "1"
            else
                echo "0"
            fi
            ;;
        "$BOT")
            if (( next_out == LEFT )); then
                echo "-1"
            elif (( next_out == RIGHT )); then
                echo "1"
            else
                echo "0"
            fi
            ;;
        "$LEFT")
            if (( next_out == TOP )); then
                echo "-1"
            elif (( next_out == BOT )); then
                echo "1"
            else
                echo "0"
            fi
            ;;
    esac
}

get_next_position () {
    local position=$1
    local direction=$2
    local direction_counter=$3

    [[ $debug -ge 2 ]] && echo "from $position with $direction at left/right $direction_counter" > /dev/tty

    # set next position + direction to incoming
    case $direction in
        "$TOP")
            position=$((position - line_length))
            direction=$BOT
            direction_counter=$((direction_counter + $(get_left_right $direction ${grid[$position]})))
            ;;
        "$RIGHT")
            position=$((position + 1))
            direction=$LEFT
            direction_counter=$((direction_counter + $(get_left_right $direction ${grid[$position]})))
            ;;
        "$BOT")
            position=$((position + line_length))
            direction=$TOP
            direction_counter=$((direction_counter + $(get_left_right $direction ${grid[$position]})))
            ;;
        "$LEFT")
            position=$((position - 1))
            direction=$RIGHT
            direction_counter=$((direction_counter + $(get_left_right $direction ${grid[$position]})))
            ;;
    esac

    [[ $debug -ge 2 ]] && echo "step to: $position $((grid[position] / direction))" > /dev/tty
    echo "$position $((grid[position] / direction)) $direction_counter"
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

transform_value_back () {
    value=$1

    case $value in
        '6')
            echo "L"
            ;;
        '10')
            echo "|"
            ;;
        '14')
            echo "J"
            ;;
        '15')
            echo "F"
            ;;
        '21')
            echo "-"
            ;;
        '35')
            echo "7"
            ;;
        '1')
            echo "."
            ;;
        *)
            echo "$value"
            ;;
    esac
}

is_valid_rim () {
    local grid_position=$1
    [[ $debug -ge 3 ]] && echo "is_valid_rim: $grid_position" > /dev/tty

    if [[ ${grid[$grid_position]} == "X" ]] || [[ "${path_index[$grid_position]}" -eq 1 ]]; then
        echo 0
        return
    fi

    echo 1
}

build_initial_rim () {
    local -n path=$1
    local -n directions=$2
    local -n output_rim=$3
    local -n grid_out=$4

    # encirclement to the right of path
    [[ $debug -ge 1 ]] && echo "build_rim: right" > /dev/tty
    for (( index=0; index<${#path[@]}; index++ )); do
        # check direct neighbor
        case ${directions[$index]} in
            "$TOP")
                value=$((${path[$index]} + 1))
                [[ $debug -ge 3 ]] && echo "build_rim: right ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
            "$RIGHT")
                value=$((${path[$index]} + line_length))
                [[ $debug -ge 3 ]] && echo "build_rim: bot ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
            "$BOT")
                value=$((${path[$index]} - 1))
                [[ $debug -ge 3 ]] && echo "build_rim: left ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
            "$LEFT")
                value=$((${path[$index]} - line_length))
                [[ $debug -ge 3 ]] && echo "build_rim: top ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
        esac

        # check diagonal neighbors
        case ${directions[$index]} in
            "$TOP")
                value=$((${path[$index]} + 1 - line_length))
                [[ $debug -ge 3 ]] && echo "build_rim: top right ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
            "$RIGHT")
                value=$((${path[$index]} + line_length + 1))
                [[ $debug -ge 3 ]] && echo "build_rim: right bot ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
            "$BOT")
                value=$((${path[$index]} - 1 + line_length))
                [[ $debug -ge 3 ]] && echo "build_rim: bot left ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
            "$LEFT")
                value=$((${path[$index]} - line_length))
                [[ $debug -ge 3 ]] && echo "build_rim: left top ${grid_out[$value]}" > /dev/tty
                if [[ $(is_valid_rim $value) -eq 1 ]]; then
                    output_rim+=($value)
                    grid_out[$value]="X"
                fi
                ;;
        esac
    done
}

flood_encirclements () {
    local -n grid_in=grid
    local current_rim=("$@")
    local next_rim=()
    local counter=${#current_rim[@]}

    [[ $debug -ge 1 ]] && echo "flood_encirclements: ${current_rim[*]}" > /dev/tty

    for position in "${current_rim[@]}"; do
        #top
        curr=$((position - line_length))
        if [[ $(is_valid_rim $curr) -eq 1 ]]; then
            grid_in[$curr]="X"
            next_rim+=($curr)
        fi

        #left
        curr=$((position + 1))
        if [[ $(is_valid_rim $curr) -eq 1 ]]; then
            grid_in[$curr]="X"
            next_rim+=($curr)
        fi

        #bot
        curr=$((position + line_length))
        if [[ $(is_valid_rim $curr) -eq 1 ]]; then
            grid_in[$curr]="X"
            next_rim+=($curr)
        fi

        #right
        curr=$((position - 1))
        if [[ $(is_valid_rim $curr) -eq 1 ]]; then
            grid_in[$curr]="X"
            next_rim+=($curr)
        fi
    done

    if [[ ${#next_rim[@]} -gt 0 ]]; then
        counter=$((counter + $(flood_encirclements ${next_rim[*]})))
    fi

    echo $counter
}

output_new_grid () {
    rm -f output
    touch output
    for (( index=0; index<${#grid[@]}; index++ )); do
        if [[ $((index % line_length)) -eq 0 ]]; then
            echo >> output
        fi
        echo -n "$(transform_value_back "${grid[index]}")" >> output
    done
    echo >> output
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

#switch left/right
direction_selector=0

full_path+=("$start_position")
path_index["$start_position"]=1
full_directions+=("${outgoing_direction[$direction_selector]}")
walker=("${current_positions[$direction_selector]}" "${outgoing_direction[$direction_selector]}" 0)
full_path+=("${walker[0]}")
path_index["${walker[0]}"]=1
full_directions+=("${walker[1]}")
[[ $debug -ge 1 ]] && echo "detected ${walker[2]} direction" > /dev/tty

declare -a rim=()
# run while not equal
counter=0
while [[ "${walker[0]}" -ne $start_position ]]; do
    walker=($(get_next_position "${walker[0]}" "${walker[1]}" "${walker[2]}"))
    full_path+=("${walker[0]}")
    path_index["${walker[0]}"]=1
    full_directions+=("${walker[1]}")
    counter=$((counter + 1))
done

# ${walker[2]} < 0 means loop encloses left, > 0 right
# # reverse if left
# if [[ ${walker[2]} -lt 0 ]]; then
#     for (( index=0; index<${#full_path[@]}; index++ )); do
#         temp=${full_path[index]}
#         full_path[index]=${full_path[counter-index]}
#         full_path[counter - index]=$temp
#     done
# fi

echo "${walker[2]}"
echo "${full_path[*]}"
echo "${full_directions[*]}"

declare -a rim=()
build_initial_rim full_path full_directions rim grid

[[ $debug -ge 1 ]] && echo "rim ${rim[*]}" > /dev/tty

echo "final count: $(flood_encirclements ${rim[*]})"

output_new_grid
