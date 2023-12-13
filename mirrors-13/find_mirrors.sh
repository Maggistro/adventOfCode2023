#!/bin/bash

debug=${1:0}
readarray -t lines < mirrors-13/input


check_vertical_mirror () {
    local input=$1
    local length=${#input}
    local pos=0

    [[ $debug -ge 2 ]] && echo "entry: $input" > /dev/tty

    #check even
    if [[ $((length % 2)) -eq 0 ]]; then
        if [[ ${input:0:$((length/2))} == $(rev <<< ${input:$((length/2))}) ]]; then
            echo $((length/2))
        else
            echo -1
        fi
    else 
        # cut front
        if [[ "${input:1:$((length/2))}" == $(rev <<< ${input:$((length/2 + 1))}) ]]; then
            echo $((length/2 + 1))
        # cut back
        elif [[ ${input:0:$((length/2))} == $(rev <<< ${input:$((length/2)):$((length/2))}) ]]; then
            echo $((length/2))
        else           
            echo -1
        fi
    fi
}

flip () {
    local input=( "$@" )
    local length=${#input[0]}
    local height=${#input}
    local temp=()

    for (( i=0; i<length; i++ )); do
        temp+=( '' )
        for (( j=0; j<height; j++ )); do
            temp[i]=${temp[i]}${input[$j]:$i:1}
        done
    done

    echo "${temp[@]}"
}

check_block () {
    local -n block=$1

    [[ $debug -ge 2 ]] && echo "block: ${block[@]}" > /dev/tty

    local pos=-1
    # check vertical
    for entry in "${block[@]}"; do
        pos=$(check_vertical_mirror $entry)
        if [[ $pos -eq -1 ]]; then
            [[ $debug -ge 2 ]] && echo "no vertical mirror" > /dev/tty
            break
        fi
    done

    if [[ $pos -ne -1 ]]; then
        echo $pos
        return
    fi

    block=( $(flip "${block[@]}") )
    # check horizontal

    for entry in "${block[@]}"; do
        pos=$(check_vertical_mirror $entry)
        if [[ $pos -eq -1 ]]; then
            [[ $debug -ge 2 ]] && echo "no horizontal mirror" > /dev/tty
            break
        fi
    done

    echo $((pos * 100))
}

temp=()
linePos=0
sum=0
for (( linePos=0; linePos<${#lines[@]}; linePos++ )); do
    if [[ ${lines[$linePos]} == '' ]]; then
        sum=$((sum + $(check_block temp)))
        temp=()
        echo $sum > /dev/tty
    else
        temp+=( "${lines[$linePos]}" )
    fi
done

echo $sum