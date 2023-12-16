#!/bin/bash
NORTH=2
EAST=3
SOUTH=5
WEST=7

debug=${1:0}
readarray -t cave < energy-16/input
declare -A visited
declare -A positions=()

MAX=${#cave[0]}
MIN=-1

get_next_rim () {
    local coordinates=$1
    local -n visitedRim=visited
    local -n positionsRim=positions

    [[ $debug -ge 2 ]] && echo -n "coordinates $coordinates: " > /dev/tty

    if [[ ${visitedRim[$coordinates]} -eq 1 || $coordinates =~ $MAX || $coordinates =~ $MIN ]]; then
        [[ $debug -ge 2 ]] && echo "canceled" > /dev/tty
        return
    fi

    visitedRim["$1"]=1
    IFS=',' read -r x y direction <<< "$coordinates"
    positionsRim["$x,$y"]=1

    local symbol=${cave[$y]:$x:1}
    local rim=()

    [[ $debug -ge 2 ]] && echo "symbol $symbol" > /dev/tty

    case $symbol in
        '|') case $direction in
                $NORTH) rim+=( "$x,$((y-1)),$direction" );;
                $SOUTH) rim+=( "$x,$((y+1)),$direction" );;
                $EAST);&
                $WEST)
                    rim+=( "$x,$((y-1)),$NORTH" )
                    rim+=( "$x,$((y+1)),$SOUTH" )
                ;;
            esac ;;
        '-') case $direction in
                $EAST) rim+=( "$((x+1)),$y,$direction" );;
                $WEST) rim+=( "$((x-1)),$y,$direction" );;
                $NORTH);&
                $SOUTH)
                    rim+=( "$((x+1)),$y,$EAST" )
                    rim+=( "$((x-1)),$y,$WEST" )
                ;;
            esac ;;
        '\') case $direction in
                $NORTH) rim+=( "$((x-1)),$y,$WEST" );;
                $SOUTH) rim+=( "$((x+1)),$y,$EAST" );;
                $EAST) rim+=( "$x,$((y+1)),$SOUTH" );;
                $WEST) rim+=( "$x,$((y-1)),$NORTH" );;
            esac ;;
        '/') case $direction in
                $NORTH) rim+=( "$((x+1)),$y,$EAST" );;
                $SOUTH) rim+=( "$((x-1)),$y,$WEST" );;
                $EAST) rim+=( "$x,$((y-1)),$NORTH" );;
                $WEST) rim+=( "$x,$((y+1)),$SOUTH" );;
            esac ;;
        '.') case $direction in
                $NORTH) rim+=( "$x,$((y-1)),$NORTH" );;
                $SOUTH) rim+=( "$x,$((y+1)),$SOUTH" );;
                $EAST) rim+=( "$((x+1)),$y,$EAST" );;
                $WEST) rim+=( "$((x-1)),$y,$WEST" );;
            esac ;;
        *) echo "error: unknown symbol $symbol" > /dev/tty; exit 1;;
    esac

    for coord in "${rim[@]}"; do
        get_next_rim "$coord"
    done
}

print_block () {
    for (( y=0; y<${#cave[@]}; y++)); do
        for (( x=0; x<${#cave[$y]}; x++ )); do
            if [[ ${positions["$x,$y"]} -eq 1 ]]; then
                echo -n '#' > /dev/tty
            else
                echo -n "${cave[$y]:$x:1}" > /dev/tty
            fi
        done

        echo  > /dev/tty
    done
    echo "" > /dev/tty
}

get_next_rim "0,0,$EAST"

# print_block

echo "energized fields ${#positions[@]}"