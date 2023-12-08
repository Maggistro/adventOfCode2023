#!/bin/bash
red=12
green=13
blue=14

get_game_min () {
    gameData=$1
    IFS=':' read -ra main <<< "$gameData"
    IFS=' ' read -ra game <<< "${main[0]}"
    IFS=';' read -ra rounds <<< "${main[1]}"

    # min values
    minRed=0
    minGreen=0
    minBlue=0

    # max per round
    for ((round=0; round<${#rounds[@]}; round++)); do
        IFS=',' read -ra colors <<< "${rounds[$round]}"

        for ((color=0; color<${#colors[@]}; color++)); do

            IFS=' ' read -ra range <<< $(echo "${colors[$color]}" | sed 's/ *$//g')
            if [[ ${range[1]} == "red" ]] && [[ ${range[0]} -gt $minRed ]]; then
                minRed=${range[0]}
            fi
            if [[ ${range[1]} == "green" ]] && [[ ${range[0]} -gt $minGreen ]]; then
                minGreen=${range[0]}
            fi
            if [[ ${range[1]} == "blue" ]] && [[ ${range[0]} -gt $minBlue ]]; then
                minBlue=${range[0]}
            fi
        done
    done

    echo "$((minRed * minGreen * minBlue))"
}

get_game_max () {
    gameData=$1
    IFS=':' read -ra main <<< "$gameData"
    IFS=' ' read -ra game <<< "${main[0]}"
    IFS=';' read -ra rounds <<< "${main[1]}"

    # game id
    gameId=${game[1]}
    possible=1

    # max per round
    for ((round=0; round<${#rounds[@]}; round++)); do
        IFS=',' read -ra colors <<< "${rounds[$round]}"

        for ((color=0; color<${#colors[@]}; color++)); do

            IFS=' ' read -ra range <<< $(echo "${colors[$color]}" | sed 's/ *$//g')
            if [[ ${range[1]} == "red" ]] && [[ ${range[0]} -gt $red ]]; then
                possible=0
            fi
            if [[ ${range[1]} == "green" ]] && [[ ${range[0]} -gt $green ]]; then
                possible=0
            fi
            if [[ ${range[1]} == "blue" ]] && [[ ${range[0]} -gt $blue ]]; then
                possible=0
            fi
        done
    done

    if [[ $possible -eq 1 ]]; then
        echo "$gameId"
    else
        echo 0
    fi
}

sum=0
while read -r line; do
    id=$(get_game_min "$line")
    sum=$((sum + id))
done < input

echo $sum

# line="Game 1: 10 green, 9 blue, 1 red; 1 red, 7 green; 11 green, 6 blue; 8 blue, 12 green"
# line="Game 3: 2 red, 7 green, 1 blue; 1 blue, 8 red; 7 green, 19 red, 5 blue; 1 blue, 10 green, 18 red; 10 red, 6 blue, 4 green"
# line="Game 29: 4 blue, 3 red, 13 green; 9 green, 2 red, 1 blue; 11 green, 5 blue, 2 red; 1 blue, 7 green, 2 red; 4 blue, 1 red, 12 green"

# total=$(get_game_min "$line")
# echo "$total"