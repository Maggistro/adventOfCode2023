#!/bin/bash

matrix_length=$(head -n 1 input | awk '{print length}')
matrix=$(cat input | awk '{print}' ORS='')

check_active () {
    start=$1
    end=$2


    total_length=$(echo "$matrix" | awk '{print length}')
    #check backwards
    for (( pos=start-1; pos<=end+1; pos++)); do
        #inline
        if [[ pos -ge 0 ]]; then
            if [[ ${matrix:$pos:1} != '.' ]] && [[ ! ${matrix:$pos:1} =~ ^[0-9]+$ ]]; then
                return 1
            fi
        fi

        #above
        if [[ $((pos - matrix_length)) -ge 0 ]]; then
            if [[ ${matrix:$((pos - matrix_length)):1} != '.' ]] && [[ ! ${matrix:$((pos - matrix_length)):1} =~ ^[0-9]+$ ]]; then
                return 1
            fi
        fi

        #below
        if [[ $((pos + matrix_length)) -le $total_length ]]; then
            if [[ ${matrix:$((pos + matrix_length)):1} != '.' ]] && [[ ! ${matrix:$((pos + matrix_length)):1} =~ ^[0-9]+$ ]]; then
                return 1
            fi
        fi
    done

    return 0
}

find_digits () {
    start=-1
    end=-1
    sum=0

    for (( current=0; current<${#matrix}; current++)); do

        #check digit
        if [[ ${matrix:$current:1} =~ ^[0-9]+$ ]]; then
            if [[ $start -eq -1 ]]; then
                start=$current
            fi
            end=$current
        else
            if [[ $start -ne -1 ]]; then
                check_active $start $end
                if [[ $? -eq 1 ]]; then
                    sum=$(($sum + ${matrix:$start:$((end - start + 1))}))
                fi

                start=-1
                end=-1
            fi
        fi
    done

    echo $sum
}


find_digits
