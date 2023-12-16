#!/bin/bash
NORTH=2
EAST=3
SOUTH=5
WEST=7

debug=${1:0}
readarray -t cave < energy-16/miniinput
declare -A visited=()
declare -A positions=()
declare -A paths=()
declare -A pathPositions=()

MAX=${#cave[0]}
MIN=-1

is_valid_coordinate () {
    local coordinate=$1
    if [[  $coordinate =~ $MIN || $coordinate =~ $MAX || ${visitedRim[$coordinate]} -eq 1 ]]; then
        echo 0
        return
    fi

    echo 1
}

get_path_end () {
    local current_path=$1
    local end=""
    local counter=0
    for (( i=${#current_path}-3; i>0; i-- )); do
        [[ $debug -ge 3 ]] && echo "i: $i, char: ${current_path:$i:1}" > /dev/tty
        if [[ ${current_path:$i:1} == '#' ]]; then
            end=${current_path:$((i+1)):$counter}
            break
        fi
        counter=$((counter + 1))
    done

    if [[ $end == "" ]]; then
        end=${current_path:0:$((counter+1))}
    fi

    echo $end
}

get_next_rim () {
    local coordinates=$1
    local pathStart=$2
    local -n visitedRim=visited
    local -n positionsRim=positions
    local -n pathRim=paths
    local -n pathSteps=pathPositions

    [[ $debug -ge 2 ]] && echo -n "coordinates $coordinates: " > /dev/tty

    # cancel on border or repeat
    if [[ $(is_valid_coordinate $coordinates) -eq 0 ]]; then
        if [[ ${pathRim[$pathStart]:(-2)} != '##' ]]; then
            pathRim[$pathStart]=${pathRim[$pathStart]}"#"
        fi
        [[ $debug -ge 2 ]] && echo "canceled" > /dev/tty
        return
    fi

    # mark visited with direction
    visitedRim["$coordinates"]=1

    local x
    local y
    local direction
    IFS=',' read -r x y direction <<< "$coordinates"
    # count path
    if [[ ${pathRim[$pathStart]:a} ]] && [[ ${pathRim[$pathStart]:(-2)} == '##' ]]; then
        # skip ahead to end
        [[ $debug -ge 2 ]] && echo "rewrite $coordinates to $(get_path_end "${pathRim[$pathStart]}")" > /dev/tty
        coordinates=$(get_path_end "${pathRim[$pathStart]}")
        IFS=',' read -r x y direction <<< "$coordinates"
    else
        #create new path/append
        pathRim["$pathStart"]=${pathRim["$pathStart"]}$coordinates"#"
        pathSteps["$pathStart"]=${pathSteps["$pathStart"]}$x,$y"#"
    fi
    [[ $debug -ge 2 ]] && echo -n "path: ${pathRim[$pathStart]} " > /dev/tty

    # count visited position. (x,y) only
    if [[ ${positionsRim["$x,$y"]:a} ]]; then
        positionsRim["$x,$y"]=$((${positionsRim["$x,$y"]} + 1))
    else
        positionsRim["$x,$y"]=0
    fi

    # switch by symbol
    local symbol=${cave[$y]:$x:1}

    [[ $debug -ge 2 ]] && echo "symbol $symbol" > /dev/tty

    case $symbol in
        '|') case $direction in
                $NORTH) get_next_rim "$x,$((y-1)),$direction" "$pathStart";;
                $SOUTH) get_next_rim "$x,$((y+1)),$direction" "$pathStart";;
                $EAST);&
                $WEST) # trigger new path creations
                    northStart="$x,$((y-1)),$NORTH"
                    if [[ $(is_valid_coordinate $northStart) -eq 1 ]]; then
                        # if [[ ${pathRim[$northStart]:a} ]]; then
                        #     [[ $debug -ge 2 ]] && echo "existing path found: $northStart"
                        #     visitedRim[$northStart]=1
                        # else
                        #     [[ $debug -ge 2 ]] && echo "new path found: $northStart"
                        if [[ ${pathRim[$pathStart]:(-2)} != '##' ]]; then
                            pathRim[$pathStart]=${pathRim[$pathStart]}"#"
                        fi
                        get_next_rim "$northStart" "$northStart"
                        # fi
                    fi

                    southStart="$x,$((y+1)),$SOUTH"
                    if [[ $(is_valid_coordinate $southStart) -eq 1 ]]; then
                        # if [[ ${pathRim[$southStart]:a} ]]; then
                        #     [[ $debug -ge 2 ]] && echo "existing path found: $southStart"
                        #     visitedRim[$southStart]=1
                        # else
                        #     [[ $debug -ge 2 ]] && echo "new path found: $southStart"
                        if [[ ${pathRim[$pathStart]:(-2)} != '##' ]]; then
                            pathRim[$pathStart]=${pathRim[$pathStart]}"#"
                        fi
                        get_next_rim "$southStart" "$southStart"
                        # fi
                    fi

                    if [[ ${pathRim[$pathStart]:(-2)} != '##' ]]; then
                        pathRim[$pathStart]=${pathRim[$pathStart]}"#"
                    fi
                ;;
            esac ;;
        '-') case $direction in
                $EAST) get_next_rim "$((x+1)),$y,$direction" "$pathStart";;
                $WEST) get_next_rim "$((x-1)),$y,$direction" "$pathStart";;
                $NORTH);&
                $SOUTH) # trigger new path creations
                    eastStart="$((x+1)),$y,$EAST"
                    if [[ $(is_valid_coordinate $eastStart) -eq 1 ]]; then
                        # if [[ ${pathRim[$eastStart]:a} ]]; then
                        #     [[ $debug -ge 2 ]] && echo "existing path found: $eastStart"
                        #     visitedRim[$eastStart]=1
                        # else
                        #     [[ $debug -ge 2 ]] && echo "new path found: $eastStart"
                        if [[ ${pathRim[$pathStart]:(-2)} != '##' ]]; then
                            pathRim[$pathStart]=${pathRim[$pathStart]}"#"
                        fi
                        get_next_rim "$eastStart" "$eastStart"
                        # fi
                    fi

                    westStart="$((x-1)),$y,$WEST"
                    if [[ $(is_valid_coordinate $westStart) -eq 1 ]]; then
                        # if [[ ${pathRim[$westStart]:a} ]]; then
                        #     [[ $debug -ge 2 ]] && echo "existing path found: $westStart"
                        #     visitedRim[$westStart]=1
                        # else
                        #     [[ $debug -ge 2 ]] && echo "new path found: $westStart"
                        if [[ ${pathRim[$pathStart]:(-2)} != '##' ]]; then
                            pathRim[$pathStart]=${pathRim[$pathStart]}"#"
                        fi
                        get_next_rim "$westStart" "$westStart"
                        # fi
                    fi

                    if [[ ${pathRim[$pathStart]:(-2)} != '##' ]]; then
                        pathRim[$pathStart]=${pathRim[$pathStart]}"#"
                    fi
                ;;
            esac ;;
        '\') case $direction in
                $NORTH) get_next_rim "$((x-1)),$y,$WEST" "$pathStart";;
                $SOUTH) get_next_rim "$((x+1)),$y,$EAST" "$pathStart";;
                $EAST) get_next_rim "$x,$((y+1)),$SOUTH" "$pathStart";;
                $WEST) get_next_rim "$x,$((y-1)),$NORTH" "$pathStart";;
            esac ;;
        '/') case $direction in
                $NORTH) get_next_rim "$((x+1)),$y,$EAST" "$pathStart";;
                $SOUTH) get_next_rim "$((x-1)),$y,$WEST" "$pathStart";;
                $EAST) get_next_rim "$x,$((y-1)),$NORTH" "$pathStart";;
                $WEST) get_next_rim "$x,$((y+1)),$SOUTH" "$pathStart";;
            esac ;;
        '.') case $direction in
                $NORTH) get_next_rim "$x,$((y-1)),$NORTH" "$pathStart";;
                $SOUTH) get_next_rim "$x,$((y+1)),$SOUTH" "$pathStart";;
                $EAST) get_next_rim "$((x+1)),$y,$EAST" "$pathStart";;
                $WEST) get_next_rim "$((x-1)),$y,$WEST" "$pathStart";;
            esac ;;
        *) echo "error: unknown symbol $symbol" > /dev/tty; exit 1;;
    esac
}

print_block () {
    for (( y=0; y<${#cave[@]}; y++)); do
        for (( x=0; x<${#cave[$y]}; x++ )); do
            if [[ ${positions["$x,$y"]:a} ]]; then
                echo -n '#' > /dev/tty
            else
                echo -n "${cave[$y]:$x:1}" > /dev/tty
            fi
        done

        echo  > /dev/tty
    done
    echo "" > /dev/tty
}

calculate_field_count () {
    local sum=0
    local used_paths=()
    local outerPath=()
    local leftOvers=()

    # get walked paths
    for coords in "${!visited[@]}"; do
        if [[ ${pathPositions[$coords]:a} ]]; then
            used_paths+=("${pathPositions[$coords]}")
            [[ $debug -ge 2 ]] && echo "used: ${pathPositions[$coords]}" > /dev/tty
        else
            leftOvers+=("$coords")
        fi
    done

    # remove duplicates
    for (( outer=0; outer<${#used_paths[@]}; outer++ )); do
        IFS='#' read -r -a outerPath <<< "${used_paths[$outer]}"
        remove=0
        for (( inner=outer+1; inner<${#used_paths[@]}; inner++ )); do
            # remove element by element
            IFS='#' read -r -a temp <<< "${used_paths[$inner]}"
            for part in "${temp[@]}"; do
                if [[ $(fgrep -w $part <<< "${outerPath[@]}") ]]; then
                    remove=$((remove + 1))
                fi
            done
        done
        [[ $debug -eq 2 ]] && echo "path from ${used_paths[$outer]} reduced by $remove" > /dev/tty
        sum=$((sum + ${#outerPath[@]} - remove))
    done

    [[ $debug -ge 1 ]] && echo "leftover: ${#visited[@]}" > /dev/tty

    echo $sum
}

start="0,0,$EAST"

for (( i=0; i<10; i++ )); do
    SECONDS=0

    get_next_rim "$start" "$start"

    echo "summed paths: $(calculate_field_count)"
    echo "energized fields ${#positions[@]}"
    duration=$SECONDS
    echo "time elapsed: $duration"
done
