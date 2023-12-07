#!/bin/bash
debug=$1
readarray -t hands < poker/miniinput

five=()
four=()
full_house=()
three=()
two_pair=()
one_pair=()
high_card=()

get_type_value () {
    local -n cards_counter=$1
    local joker_count=${cards_counter[9]}

    [[ $debug -ge 2 ]] && echo ${cards_counter[*]} $joker_count > /dev/tty

    for (( card=0; card<${#cards_counter[@]}; card++ )); do
        case ${cards_counter[card]} in
            5)
                echo 7
                return
                ;;
            4)
                if [[ $joker_count -eq 0 ]]; then
                    echo 6
                elif [[ $joker_count -ge 1 ]]; then
                    echo 7
                fi
                return
                ;;
            3)
                if [[ $joker_count -eq 1 ]]; then
                    echo 6
                elif [[ "${cards_counter[*]}" =~ "2" ]] && [[ $joker_count -ne 2 ]]; then
                    echo 5
                elif [[ $joker_count -eq 2 ]]; then
                    echo 7
                elif [[ $joker_count -eq 3 ]]; then
                    echo 6
                else
                    echo 4
                fi
                return
                ;;
            2)
                if [[ "${cards_counter[*]}" =~ "3" ]]; then
                    if [[ $joker_count -eq 3 ]] || [[ $joker_count -eq 2 ]]; then
                        echo 7
                    else
                        echo 5
                    fi
                elif [[ "${cards_counter[*]}" =~ 2.+2 ]]; then
                    if [[ $joker_count -eq 1 ]]; then
                        echo 5
                    elif [[ $joker_count -eq 2 ]]; then
                        echo 6
                    else
                        echo 3
                    fi
                elif [[ $joker_count -eq 1 ]]; then
                    echo 4
                else
                    echo 2
                fi
                return
                ;;
            *) :;;
        esac
    done

    if [[ $joker_count -eq 1 ]]; then
        echo 2
        return
    fi

    echo 1
}

map_hand_to_type () {
    local hand=$1
    #            2 3 4 5 6 7 8 9 T J/W Q/X K/Y A/Z
    local cards=(0 0 0 0 0 0 0 0 0 0   0   0   0)

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
            W) cards[9]=$((cards[9] + 1));; # J
            X) cards[10]=$((cards[10] + 1));; # Q
            Y) cards[11]=$((cards[11] + 1));; # K
            Z) cards[12]=$((cards[12] + 1));; # A
        esac
    done

    echo $(get_type_value cards)
}

for (( hand_number=0; hand_number<${#hands[@]}; hand_number++ )); do
    IFS=' ' read -ra hand_parts <<< "${hands[hand_number]}"

    # replace J/Q/K/A with W/X/Y/Z for sorting
    hand=$(sed s/J/W/g <<< ${hand_parts[0]})
    hand=$(sed s/Q/X/g <<< $hand)
    hand=$(sed s/K/Y/g <<< $hand)
    hand=$(sed s/A/Z/g <<< $hand)

    case $(map_hand_to_type $hand) in
        7)
            five+=("$hand#${hand_parts[1]}")
            ;;
        6)
            four+=("$hand#${hand_parts[1]}")
            ;;
        5)
            full_house+=("$hand#${hand_parts[1]}")
            ;;
        4)
            three+=("$hand#${hand_parts[1]}")
            ;;
        3)
            two_pair+=("$hand#${hand_parts[1]}")
            ;;
        2)
            one_pair+=("$hand#${hand_parts[1]}")
            ;;
        1)
            high_card+=("$hand#${hand_parts[1]}")
            ;;
    esac
done

total_value=0
counter=1
IFS=$'\n' high_card_sorted=($(sort <<<"${high_card[*]}"))
for entry in "${high_card_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    [[ $debug -ge 1 ]] && echo "high $entry $total_value $counter" > /dev/tty
done

IFS=$'\n' one_pair_sorted=($(sort <<<"${one_pair[*]}"))
for entry in "${one_pair_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    [[ $debug -ge 1 ]] && echo "onepair $entry $total_value $counter" > /dev/tty
done

IFS=$'\n' two_pair_sorted=($(sort <<<"${two_pair[*]}"))
for entry in "${two_pair_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    [[ $debug -ge 1 ]] && echo "twopair $entry $total_value $counter" > /dev/tty
done

IFS=$'\n' three_sorted=($(sort <<<"${three[*]}"))
for entry in "${three_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    [[ $debug -ge 1 ]] && echo "three $entry $total_value $counter" > /dev/tty
done

IFS=$'\n' full_house_sorted=($(sort <<<"${full_house[*]}"))
for entry in "${full_house_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    [[ $debug -ge 1 ]] && echo "full $entry $total_value $counter" > /dev/tty
done

IFS=$'\n' four_sorted=($(sort <<<"${four[*]}"))
for entry in "${four_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    [[ $debug -ge 1 ]] && echo "four $entry $total_value $counter" > /dev/tty
done

IFS=$'\n' five_sorted=($(sort <<<"${five[*]}"))
for entry in "${five_sorted[@]}"; do
    total_value=$((total_value + (${entry:6} * counter)))
    counter=$((counter + 1))
    [[ $debug -ge 1 ]] && echo "five $entry $total_value $counter" > /dev/tty
done

echo $total_value