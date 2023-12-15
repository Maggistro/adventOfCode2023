#!/bin/bash

debug=${1:0}
readarray -t lines < ./mirrors-13/input


check_vertical_mirror () {
    local ignore_left=$1
    local input=$2
    local length=${#input}
    local pos=0

    [[ $debug -ge 3 ]] && echo "entry: $input" > /dev/tty

    #check even
    if [[ $((length % 2)) -eq 0 ]]; then
        # [[ $length -eq 10 ]] &&  echo $input > /dev/tty
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
    local input=$1
    local left=$2
    shift
    shift
    local possiblePosition=( "$@" )
    local validPositions=()
    local length=${#input}
    
    if [[ $left -eq 1 ]]; then
        for pos in "${possiblePosition[@]}"; do
            if [[ ${input:0:$pos} == $(rev <<< "${input:$pos:$pos}") ]]; then
                validPositions+=( $pos )
            fi
        done
    else
        for pos in "${possiblePosition[@]}"; do
            if [[ ${input:$((pos - length + pos)):$((length - pos))} == $(rev <<< "${input:$pos}") ]]; then
                validPositions+=( $pos )
            fi
        done
    fi

    echo "${validPositions[@]}"
}  

check_block () {
    local -n block=$1

    # [[ $debug -ge 2 ]] && print_block block

    #detect_all_mirrors
    # ignore right
    first_enty=${block[0]};
    left_positions=()
    for (( i=${#first_enty}; i>1; i-- )); do
        result=$(check_vertical_mirror 0 ${first_enty:0:$i})
        if [[  $result -ne -1 ]]; then
            left_positions+=($result)
        fi
    done

    [[ $debug -ge 2 ]] && echo "found left ${#left_positions[@]}" > /dev/tty

    for entry in "${block[@]}"; do
        left_positions=( $(check_subset $entry 1 ${left_positions[@]}) )
        if [[ ${#left_positions[@]} -eq 0 ]]; then
            [[ $debug -ge 2 ]] && echo "no left mirror" > /dev/tty
            # all eliminated
            break
        fi
    done

    if [[ ${#left_positions[@]} -gt 0 ]]; then
        echo ${left_positions[0]}
        return
    fi

    # ignore left
    right_position=()
    for (( i=0; i<${#first_enty}; i++ )); do
        result=$(check_vertical_mirror 1 ${first_enty:$i})
        if [[  $result -ne -1 ]]; then
            right_position+=( $((result + i)))
        fi
    done

    [[ $debug -ge 2 ]] && echo "found right ${right_position[@]}" > /dev/tty
    
    if [[ ${#right_position[@]} -gt 0 ]]; then
        for entry in "${block[@]}"; do
            right_position=( $(check_subset $entry 0 ${right_position[@]}) )
            if [[ ${#right_position[@]} -eq 0 ]]; then
                [[ $debug -ge 2 ]] && echo "no right mirror" > /dev/tty
                # all eliminated
                echo 0
                return
            fi
        done
    fi

    echo ${right_position[0]};
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
            
            [[ $debug -ge 2 ]] && echo "check flipped" > /dev/tty
            result=$(( $(check_block flipped) * 100 ))
            
            if [[ $result -eq 0 ]]; then
                echo "ERROR: No match found for:" > /dev/tty
                print_block temp
            fi
        fi
        sum=$((sum + result))
        temp=()
        echo $sum > /dev/tty
    else
        temp+=( "${lines[$linePos]}" )
    fi
done

echo $sum