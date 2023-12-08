#!/bin/bash

extract_number () {
    numberFound=$1
    number=""
    matrix=$(cat .temp)

    offset=0
    while [[ ${matrix:$((numberFound + offset)):1} =~ [0-9] ]]; do
        number="$number${matrix:$((numberFound + offset)):1}"
        matrix=$(sed s/./\./$((numberFound + offset + 1)) <<< $matrix)
        offset=$((offset + 1))
    done

    offset=1
    while [[ ${matrix:$((numberFound - offset)):1} =~ [0-9] ]]; do
        number="${matrix:$((numberFound - offset)):1}$number"
        matrix=$(sed s/./\./$((numberFound - offset + 1)) <<< $matrix)
        offset=$((offset + 1))
    done

    echo "$matrix" > .temp

    echo "$number"
}

check_if_gear () {
    position=$1
    firstNumber=0
    secondNumber=0
    invalid=0

    total_length=$(awk '{print length}' <<< $matrix)
    #inline
    for (( pos=position-1; pos<=position+1; pos++)); do
        matrix=$(cat .temp)

        if [[ $pos -ge 0 ]] && [[ $pos -ne $position ]]; then
            if [[ ${matrix:$pos:1} =~ [0-9] ]]; then
                if [[ $firstNumber -eq 0 ]]; then
                    firstNumber=$(extract_number $pos)
                elif [[ $secondNumber -eq 0 ]]; then
                    secondNumber=$(extract_number $pos)
                else
                    invalid=1
                fi
            fi
        fi

        #above
        if [[ $((pos - matrix_length)) -ge 0 ]]; then
            if [[ ${matrix:$((pos - matrix_length)):1} =~ [0-9] ]]; then
                if [[ $firstNumber -eq 0 ]]; then
                    firstNumber=$(extract_number $((pos - matrix_length)))
                elif [[ $secondNumber -eq 0 ]]; then
                    secondNumber=$(extract_number $((pos - matrix_length)))
                else
                    invalid=1
                fi
            fi
        fi

        #below
        if [[ $((pos + matrix_length)) -le $total_length ]]; then
            if [[ ${matrix:$((pos + matrix_length)):1} =~ [0-9] ]]; then
                if [[ $firstNumber -eq 0 ]]; then
                    firstNumber=$(extract_number $((pos + matrix_length)))
                elif [[ $secondNumber -eq 0 ]]; then
                    secondNumber=$(extract_number $((pos + matrix_length)))
                else
                    invalid=1
                fi
            fi
        fi
    done

    echo "$position $firstNumber $secondNumber $invalid" > /dev/tty

    if [[ $invalid -eq 0 ]] && [[ $firstNumber -ne 0 ]] && [[ $secondNumber -ne 0 ]]; then
        echo $(($firstNumber * $secondNumber))
    else
        echo 0
    fi
}

find_gears () {
    sum=0
    matrix=$(cat .temp)

    for (( current=0; current<${#matrix}; current++)); do
        #check *
        if [[ ${matrix:$current:1} == '*' ]]; then
            gear_ratio=$(check_if_gear $current)
            sum=$(($sum + $gear_ratio))
        fi
    done

    echo $sum
}


matrix_length=$(head -n 1 input | awk '{print length}')
matrix=$(cat input | awk '{print}' ORS='')
echo "$matrix" > .temp
find_gears
