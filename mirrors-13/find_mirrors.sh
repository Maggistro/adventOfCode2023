#!/bin/bash

debug=${1:0}
readarray -t lines < ./mirrors-13/miniinput


check_vertical_mirror () {
    local ignore_left=$1
    local input=$2
    local length=${#input}
    local pos=0

    [[ $debug -ge 3 ]] && echo "entry: $input" > /dev/tty

    #check even
    if [[ $((length % 2)) -eq 0 ]]; then
        # [[ $length -eq 8 ]] &&  echo $input > /dev/tty
        [[ $length -eq 8 ]] &&  echo $input ${input:0:$((length/2))} $(rev <<< "${input:$((length/2))}") > /dev/tty
        if [[ ${input:0:$((length/2))} == $(rev <<< "${input:$((length/2))}") ]]; then
            echo $((length/2))
        else
            echo -1
        fi
    else 
        # cut front
        if [[ $ignore_left -eq 1 && "${input:1:$((length/2))}" == $(rev <<< ${input:$((length/2 + 1))}) ]]; then
            echo $((length/2 + 1))
        # cut back
        elif [[ $ignore_left -eq 0 && ${input:0:$((length/2))} == $(rev <<< ${input:$((length/2)):$((length/2))}) ]]; then
            echo $((length/2))
        else           
            echo -1
        fi
    fi
}

flip () {
    local input=( "$@" )
    local length=${#input[0]}
    local height=${#input[@]}
    local temp=()

    for (( i=0; i<length; i++ )); do
        for (( j=0; j<height; j++ )); do
            line=${input[$j]}
            temp[$i]=${temp[$i]}${line:$i:1}
        done
    done

    echo "${temp[@]}"
}

print_block () {
    local -n data=$1
    for entry in "${data[@]}"; do
        echo $entry > /dev/tty
    done
}

check_subset () {
    local pos=$1
    local length=$2
    local -n subset=$3
    
    for set in "${subset[@]}"; do
        if [[ ${set:$pos:$((length/2))} != $(rev <<< "${set:$((pos + length/2))}") ]]; then
            echo 0
            return
        fi
    done

    echo 1
}  

check_block () {
    local -n block=$1

    # [[ $debug -ge 2 ]] && print_block block

    local pos=-1
    # check vertical
    for entry in "${block[@]}"; do
        # ignore right
        for (( i=${#entry}; i>0; i-- )); do
            newPos=$(check_vertical_mirror 0 ${entry:0:$i})
            pos=$(( newPos > pos ? newPos : pos ))
        done
    done

    [[ $debug -ge 2 ]] && echo "checked left" > /dev/tty
    if [[ $pos -ne -1 ]]; then
        length=$((pos * 2))
        if [[ $(check_subset $pos $length block) -eq 1 ]]; then
            echo $pos
            return 
        fi
    fi
    [[ $debug -ge 2 ]] && echo "continue" > /dev/tty

    pos=1000000
    for entry in "${block[@]}"; do
        # ignore left
        for (( i=0; i<${#entry}; i++ )); do
            newPos=$(check_vertical_mirror 1 ${entry:$i})
            pos=$(( newPos < pos ? newPos : pos ))
        done
    done
    [[ $debug -ge 2 ]] && echo "checked right $pos" > /dev/tty

    if [[ $pos -ne -1 ]]; then
        length=$(( (${#entry} - pos) * 2 ))
        if [[ $(check_subset $pos $length  block) -eq 1 ]]; then
            echo $pos
            return
        fi
    fi
    [[ $debug -ge 2 ]] && echo "continue" > /dev/tty

    echo 0;
}

temp=()
linePos=0
sum=0
for (( linePos=0; linePos<${#lines[@]}; linePos++ )); do
    if [[ ${lines[$linePos]} == '' ]]; then
        # check vertical
        result=$(check_block temp)
        if [[ $result -eq 0 ]]; then
            flipped=( $(flip "${temp[@]}") )
            
            [[ $debug -ge 2 ]] && echo "check lines" > /dev/tty
            result=$(( $(check_block flipped) * 100 ))
        fi
        sum=$((sum + result))
        temp=()
        echo $sum > /dev/tty
    else
        temp+=( "${lines[$linePos]}" )
    fi
done

echo $sum