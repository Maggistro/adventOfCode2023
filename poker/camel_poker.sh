#!/bin/bash

readarray -t hands < poker/input

five=()
four=()
full_house=()
three=()
two_pair=()
one_pair=()
high_card=()

get_type_value () {
    local -n cards_counter=$1

    for (( card=0; card<${#cards_counter[@]}; card++ )); do
        case ${cards_counter[card]} in
            5)
                echo 7
                return
                ;;
            4)
                echo 6
                return;;
            3)
                if [[ "${cards_counter[*]}" =~ "2" ]]; then
                    echo 5
                    return
                else
                    echo 4
                    return
                fi
                ;;
            2)
                if [[ "${cards_counter[*]}" =~ "3" ]]; then
                    echo 5
                    return
                elif [[ "${cards_counter[*]}" =~ 2.+2 ]]; then
                    echo 3
                    return
                else
                    echo 2
                    return
                fi
                ;;
            *) :;;
        esac
    done

    echo 1
}

map_hand_to_type () {
    local hand=$1
    #            2 3 4 5 6 7 8 9 T J Q K A
    local cards=(0 0 0 0 0 0 0 0 0 0 0 0 0)

    for (( card=0; card<5; card++ )); do
        case ${hand:$card:1} in
            2) cards[0]=$((cards[0] + 1));;
            3) cards[1]=$((cards[1] + 1));;
            4) cards[2]=$((cards[2] + 1));;
            5) cards[3]=$((cards[3] + 1));;
            6) cards[4]=$((cards[4] + 1));;
            7) cards[5]=$((cards[5] + 1));;
            8) cards[6]=$((cards[6] + 1));;
            9) cards[7]=$((cards[7] + 1));;
            T) cards[8]=$((cards[8] + 1));;
            J) cards[9]=$((cards[9] + 1));;
            Q) cards[10]=$((cards[10] + 1));;
            K) cards[11]=$((cards[11] + 1));;
            A) cards[12]=$((cards[12] + 1));;
        esac
    done

    echo $(get_type_value cards)
}

for (( hand=0; hand<${#hands[@]}; hand++ )); do
    IFS=' ' read -ra hand_parts <<< "${hands[hand]}"

    case $(map_hand_to_type ${hand_parts[0]}) in
        7)
            five+=("${hand_parts[0]}#${hand_parts[1]}")
            ;;
        6)
            four+=("${hand_parts[0]}#${hand_parts[1]}")
            ;;
        5)
            full_house+=("${hand_parts[0]}#${hand_parts[1]}")
            ;;
        4)
            three+=("${hand_parts[0]}#${hand_parts[1]}")
            ;;
        3)
            two_pair+=("${hand_parts[0]}#${hand_parts[1]}")
            ;;
        2)
            one_pair+=("${hand_parts[0]}#${hand_parts[1]}")
            ;;
        1)
            high_card+=("${hand_parts[0]}#${hand_parts[1]}")
            ;;
    esac
done

total_value=0
counter=1
IFS=$'\n' high_card_sorted=($(sort -r <<<"${high_card[*]}"))
for entry in "${high_card_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    # echo "high $total_value $counter" > /dev/tty
done

IFS=$'\n' one_pair_sorted=($(sort -r <<<"${one_pair[*]}"))
for entry in "${one_pair_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    # echo "onepair $total_value $counter" > /dev/tty
done

IFS=$'\n' two_pair_sorted=($(sort -r <<<"${two_pair[*]}"))
for entry in "${two_pair_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    # echo "twopair $entry $total_value $counter" > /dev/tty
done

IFS=$'\n' three_sorted=($(sort -r <<<"${three[*]}"))
for entry in "${three_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    # echo "three $total_value $counter" > /dev/tty
done

IFS=$'\n' full_house_sorted=($(sort -r <<<"${full_house[*]}"))
for entry in "${full_house_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    # echo "full $total_value $counter" > /dev/tty
done

IFS=$'\n' four_sorted=($(sort -r <<<"${four[*]}"))
for entry in "${four_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    # echo "four $total_value $counter" > /dev/tty
done

IFS=$'\n' five_sorted=($(sort -r <<<"${five[*]}"))
for entry in "${five_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    # echo "five $total_value $counter" > /dev/tty
done

echo $total_value