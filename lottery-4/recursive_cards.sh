#!/bin/bash
winnerStep=0
ownedStep=0
winnerList=()
ownedList=()
cardCounts=()
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
    cardCounts+=(1)
done < input

winnerStep=${#winning[@]}
ownedStep=${#owned[@]}
lineCount=${#cardCounts[@]}

get_card_points () {
    cardNumber=$1
    local -n cards=$2
    if [[ $cardNumber -gt $lineCount ]]; then
        echo 0
        return
    fi

    ownedIndex=$((cardNumber * ownedStep))
    winnerIndex=$((cardNumber * winnerStep))

    card=${cards[$cardNumber]}
    followUps=0
    for (( number=ownedIndex; number<$((ownedIndex + ownedStep)); number++ )); do
        for (( winner=winnerIndex; winner<$((winnerIndex + winnerStep)); winner++ )); do
            if [[ ${ownedList[$number]} -eq ${winnerList[$winner]} ]]; then
                followUps=$((followUps + 1))
            fi
        done
    done

    for (( count=1; count<=followUps; count++ )); do
        cards[cardNumber + count]=$((${cards[cardNumber + count]} + card))
    done
}

for (( index=0; index<lineCount; index++ )); do
    get_card_points $index cardCounts
done

sum=0
for cardPoints in "${cardCounts[@]}"; do
    sum=$((sum + cardPoints))
done

echo $sum