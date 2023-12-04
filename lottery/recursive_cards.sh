#!/bin/bash
winnerList=()
ownedList=()
while read -r line; do
    IFS=':' read -ra main <<< "$line"
    IFS='|' read -ra sets <<< "${main[1]}"

    winnerList+=("${sets[0]}")
    ownedList+=("${sets[1]}")
done < input

get_card_points () {
    index=$1

    if [[ $index -gt ${#winnerList[@]} ]]; then
        echo 0
        return
    fi

    IFS=' ' read -ra winning <<< "${winnerList[$index]}"
    IFS=' ' read -ra owned <<< "${ownedList[$index]}"

    nextCardCount=0
    for number in ${owned[*]}; do
        for winner in ${winning[*]}; do
            if [[ $number -eq $winner ]]; then
                nextCardCount=$((nextCardCount + 1))
            fi
        done
    done

    followUps=$nextCardCount
    for (( count=0; count<followUps; count++ )); do
        subPoints=$(get_card_points $(($index + $count + 1)))
        nextCardCount=$((nextCardCount + subPoints))
    done

    echo $nextCardCount
}

sum=0
for (( index=0; index<${#winnerList[@]}; index++ )); do
    points=$(get_card_points $index)
    sum=$((sum + points))
done

sum=$((sum + ${#winnerList[@]}))

echo $sum