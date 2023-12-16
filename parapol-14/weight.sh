#!/bin/bash

debug=${1:0}
readarray -t lines < parapol-14/miniinput

rotate_right () {
    local -n rotateRightInput=$1
    local length=${#rotateRightInput[0]}
    local height=${#rotateRightInput[@]}
    local temp=()
    line=""

    for (( i=0; i<length; i++ )); do
        for (( j=0; j<height; j++ )); do
            line=$line${rotateRightInput[$j]:$i:1}
        done
        temp+=( $(rev <<< $line) )
        line=""
    done

    rotateRightInput=("${temp[@]}")
}


rotate_left () {
    local -n rotateLeftInput=$1
    local length=${#rotateLeftInput[0]}
    local height=${#rotateLeftInput[@]}
    local temp=()

    for (( j=length-1; j>=0; j-- )); do
        for (( i=0; i<height; i++)); do
            line=$line${rotateLeftInput[$i]:$j:1}
        done
        temp+=( $line )
        line=""
    done

    rotateLeftInput=("${temp[@]}")
}

cycle () {
    local cycleInput=( "$@" )

    # north
    rotate_right cycleInput
    out_north=()
    for vertical in "${cycleInput[@]}"; do
        out_north+=( $(bubble_up $vertical) )
    done
    # print_block out_north
    [[ $debug -ge 2 ]] && echo "sorted north" > /dev/tty

    # west
    rotate_right out_north
    out_west=()
    for vertical in "${out_north[@]}"; do
        out_west+=( $(bubble_up $vertical) )
    done
    # print_block out_west
    [[ $debug -ge 2 ]] && echo "sorted west" > /dev/tty

    # south
    rotate_right out_west
    out_south=()
    for vertical in "${out_west[@]}"; do
        out_south+=( $(bubble_up $vertical) )
    done
    # print_block out_south
    [[ $debug -ge 2 ]] && echo "sorted south" > /dev/tty

    # east
    rotate_right out_south
    out_east=()
    for vertical in "${out_south[@]}"; do
        out_east+=( $(bubble_up $vertical) )
    done
    # print_block out_east
    [[ $debug -ge 2 ]] && echo "sorted east" > /dev/tty

    echo "${out_east[@]}"
}

should_bubble () {
    local first=$1
    local second=$2

    [[ $debug -ge 3 ]] && echo "first: $first, second: $second" > /dev/tty
    if [[ $first == '.' && $second == 'O' ]]; then
        echo 1
    else
        echo 0
    fi
}

bubble_up () {
    local line=$1
    local newLine=$line

    for (( i=${#newLine}; i>0 ; i-- )); do
        if [[ $(should_bubble "${newLine:$((i-1)):1}" "${newLine:$i:1}" ) -eq 1 ]]; then
            newLine=${newLine:0:$((i-1))}${newLine:$i:1}${newLine:$((i-1)):1}${newLine:$((i+1))}
        fi
    done

    [[ $debug -ge 3 ]] && echo "$newLine from $line" > /dev/tty
    if [[ $newLine != "$line" ]]; then
        bubble_up $newLine
    else
        echo $newLine
    fi
}

print_block () {
    local -n data=$1
    for entry in "${data[@]}"; do
        echo $entry > /dev/tty
    done
    echo "" > /dev/tty
}

get_load () {
    local line=$1
    local load=0
    local maxDistance=${#line}

    for (( i=0; i<maxDistance; i++ )); do
        if [[ ${line:$i:1} == 'O' ]]; then
            load=$((load + maxDistance - i))
        fi
    done

    echo $load
}

rotate_left lines
rotate_left lines
# print_block lines
count=0
while :; do
    newLines=$(cycle "${lines[@]}")
    if [[ $newLines == "${lines[@]}" ]]; then
        break
    fi
    if [[ $((count % 1000)) -eq 0 ]]; then
        echo -n $count > /dev/tty
    fi
    count=$((count + 1))
    lines=( $newLines )
done

rotate_right lines
# print_block lines

# count load
load=0
for vertical in "${lines[@]}"; do
    load=$(( load + $(get_load $vertical) ))
done

echo "load is $load" > /dev/tty