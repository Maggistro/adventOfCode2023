#!/bin/bash
winnerStep=0
ownedStep=0
winnerList=()
ownedList=()
lineCount=0
while read -r line; do
    IFS=':' read -ra main <<< "$line"
    IFS='|' read -ra sets <<< "${main[1]}"
    IFS=' ' read -ra winning <<< "${sets[0]}"
    IFS=' ' read -ra owned <<< "${sets[1]}"

    for entry in "${winning[@]}"; do
        winnerList+=($entry)
    done

    for entry in "${owned[@]}"; do
        ownedList+=($entry)
    done
    lineCount=$((lineCount + 1))
done < input

winnerLength=${#winnerList[@]}
ownerLength=${#ownedList[@]}
winnerStep=${#winning[@]}
ownedStep=${#owned[@]}

get_card_points () {
    ownedIndex=$1
    winnerIndex=$2

    if [[ $winnerIndex -gt $winnerLength ]]; then
        echo 0
        return
    fi

    if [[ $ownedIndex -gt $ownerLength ]]; then
        echo 0
        return
    fi

    nextCardCount=0
    for (( number=ownedIndex; number<$((ownedIndex + ownedStep)); number++ )); do
        for (( winner=winnerIndex; winner<$((winnerIndex + winnerStep)); winner++ )); do
            if [[ ${ownedList[$number]} -eq ${winnerList[$winner]} ]]; then
                nextCardCount=$((nextCardCount + 1))
            fi
        done
    done

    followUps=$nextCardCount
    for (( count=1; count<=followUps; count++ )); do
        subPoints=$(get_card_points "$((ownedIndex + (count * ownedStep)))" "$((winnerIndex + (count * winnerStep)))")
        nextCardCount=$((nextCardCount + subPoints))
    done

    echo $nextCardCount
}

sum=0
for (( index=0; index<lineCount; index++ )); do
    points=$(get_card_points $(($index * ownedStep)) $(($index * winnerStep)))
    sum=$((sum + points))
done

sum=$((sum + lineCount))

echo $sum