#!/bin/bash

get_card_points () {
    card=$1

    IFS=':' read -ra main <<< "$card"
    IFS='|' read -ra sets <<< "${main[1]}"
    IFS=' ' read -ra winning <<< $(echo "${sets[0]}" | sed 's/ *$//g')
    IFS=' ' read -ra owned <<< $(echo "${sets[1]}" | sed 's/ *$//g')

    echo "${winning[*]}" > /dev/tty
    echo "${owned[*]}" > /dev/tty

    counter=0
    for number in ${owned[*]}; do
        for winner in ${winning[*]}; do
            if [[ $number -eq $winner ]]; then
                if [[ $counter -eq 0 ]]; then
                    counter=1
                else
                    counter=$((counter * 2))
                fi
            fi
        done
    done

    echo $counter > /dev/tty

    echo $counter
}

sum=0
while read -r line; do
    points=$(get_card_points "$line")
    sum=$(($sum + $points))
done < input

echo $sum
