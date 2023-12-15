#!/bin/bash

debug=${1:0}
readarray -t lines < parapol-14/input


flip () {
    local -n input=$1
    local length=${#input[0]}
    local height=${#input[@]}
    local temp=()

    for (( i=0; i<length; i++ )); do
        for (( j=0; j<height; j++ )); do
            line=${input[$j]}
            temp[$i]=${temp[$i]}${line:$i:1}
        done
    done

    input=("${temp[@]}")
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

    for (( i=0; i<${#newLine} - 1; i++ )); do
        if [[ $(should_bubble "${newLine:$i:1}" "${newLine:$((i+1)):1}") -eq 1 ]]; then
            newLine=${newLine:0:$i}${newLine:$((i+1)):1}${newLine:$i:1}${newLine:$((i+2))}
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

echo "flipping input" > /dev/tty
flip lines


echo "flipped" > /dev/tty
# sort input
out=()
for vertical in "${lines[@]}"; do
    out+=( $(bubble_up $vertical) )
done

echo "sorted" > /dev/tty

# print_block out

# count load
load=0
for vertical in "${out[@]}"; do
    load=$(( load + $(get_load $vertical) ))
    # echo $load > /dev/tty
done

echo "load is $load" > /dev/tty