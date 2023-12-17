#!/bin/bash

debug=${1:0}
input="crucible-17/miniinput"
tiles=( $(cat $input | tr -d '\n' | sed  's/\(.\)/\1 /g') )

# build secondary data
temp=$(head -n 1 $input)
line_length=${#temp}
total_length=${#tiles[@]}
start=0
end=$((total_length - 1))

# build node-weight map
sum=$(IFS=+; echo "$((${tiles[*]}))")
declare -A node_weights=()
for (( i=0; i<total_length; i++ )); do
    node_weights[$i]=$sum
done
bestPathValue=$sum

# create rim list
declare -A sortedRim=()


is_valid_rim () {
    local tile=$1
    local cost=$2
    local -n activeRims=sortedRim
    local tempRim=()

    if [[ $tile -lt 0 || $tile -ge $total_length ]]; then
        echo 0
        return
    fi

    if [[ $bestPathValue -lt $cost ]]; then
        echo 0
        return
    fi

    echo 1

    # if [[ ${activeRims[$tile]:a} ]]; then
    #     value=${activeRims[$tile]}
    #     tempIFS=$IFS
    #     IFS='#' read -r -a tempRim <<< $value
    #     IFS=$tempIFS
    #     if [[ ${tempRim[0]} -gt $cost ]]; then
    #         echo 1
    #     else
    #         echo 0
    #     fi
    # else
    #     echo 1
    # fi
}

get_next_rims () {
    local entry=$1
    local currentCost=$2
    local straigth=$3
    local pos=${entry:0:(-1)}
    local dir=${entry:(-1)}
    local rims=()

    case $dir in
        '^') #up left right
            if [[ $(( pos % line_length )) -ne 0 ]]; then #not left edge
                rims+=( "1#$((pos - 1))<" )
            fi

            if [[ $(((pos + 1) % line_length )) ]]; then #not right edge
                rims+=( "$((straigth + 1))#$((pos + 1))>" )
            fi

            if [[ $pos -ge $line_length && $straigth -ne 3 ]]; then #not top row
                rims+=( "$((straigth + 1))#$((pos - line_length))^" )
            fi
            ;;
        '>') #up right down
            if [[ $(((pos + 1) % line_length )) -ne 0 && $straigth -ne 3 ]]; then #not right edge
                rims+=( "$((straigth + 1))#$((pos + 1))>" )
            fi

            if [[ $pos -ge $line_length ]]; then #not top row
                rims+=( "1#$((pos - line_length))^" )
            fi

            if [[ $pos -lt $((total_length - line_length)) ]]; then #not bot row
                rims+=( "1#$((pos + line_length))v" )
            fi
            ;;
        'v') #right down left

            if [[ $(( pos % line_length )) -ne 0 ]]; then #not left edge
                rims+=( "1#$((pos - 1))<" )
            fi

            if [[ $(((pos + 1) % line_length )) -ne 0 ]]; then #not right edge
                rims+=( "1#$((pos + 1))>" )
            fi

            if [[ $pos -lt $((total_length - line_length)) && $straigth -ne 3 ]]; then #not bot row
                rims+=( "$((straigth + 1))#$((pos + line_length))v" )
            fi
            ;;
        '<') #up left down

            if [[ $((pos % (line_length - 1) )) -ne 0 && $straigth -ne 3 ]]; then #not left edge
                rims+=( "$((straigth + 1))#$((pos - 1))<" )
            fi

            if [[ $pos -ge $line_length ]]; then #not top row
                rims+=( "1#$((pos - line_length))^" )
            fi

            if [[ $pos -lt $((total_length - line_length)) ]]; then #not bot row
                rims+=( "1#$((pos + line_length))v" )
            fi
            ;;
    esac

    local returnRims=()
    local rim=""
    for rim in "${rims[@]}"; do
        rimPos=${rim:2:(-1)}
        nextCost=$((currentCost + ${tiles[$rimPos]}))
        [[ $debug -ge 4 ]] && echo "rim from $entry: ${tiles[$rimPos]} " > /dev/tty
        if [[ $(is_valid_rim $rimPos $nextCost) -eq 1 ]]; then
            returnRims+=( "$nextCost#$rim" )
        fi
    done

    [[ $debug -ge 4 ]] && echo "returnRims: ${returnRims[*]}" > /dev/tty
    echo "${returnRims[@]}"
}

print_block () {
    local -n block=$1

    for (( x=0; x<total_length; x++ )); do
        printf "%03d " ${block[$x]} > /dev/tty
        if [[ $(((x+1) % line_length)) -eq 0 ]]; then
            echo > /dev/tty
        fi
    done
}

walk () {
    local -n nodes=node_weights
    local current_rim=$1
    local current_cost=$2
    local straight_count=$3
    local current_tile=${current_rim:0:(-1)}

    [[ $debug -ge 2 ]] && echo -n "current: $current_rim - $current_cost " > /dev/tty

    if [[ $current_cost -lt ${nodes[$current_tile]} ]]; then
        [[ $debug -ge 2 ]] && echo -n "node cost ${nodes[$current_tile]} => $current_cost " > /dev/tty
        nodes[$current_tile]=$current_cost
    fi

    if [[ ${rim:0:(-1)} -eq $end ]]; then
        echo "path found with cost: $current_cost" > /dev/tty
        bestPathValue=$current_cost
        return
    fi

    local next_rims=( $(get_next_rims $current_rim $current_cost $straight_count) )

    [[ $debug -ge 2 ]] && echo "next rim: ${next_rims[*]} -> $straight_count" > /dev/tty

    for rim in "${next_rims[@]}"; do
        pos=${rim:0:(-1)}
        if [[ ${current_rim:(-1)} == ${rim:(-1)} ]]; then
            straight_count=$((straight_count + 1))
        else
            straight_count=1
        fi

        [[ $debug -ge 3 ]] && echo "next rim: $rim $straight_count" > /dev/tty
        walk "$rim" $((current_cost + ${tiles[$pos]})) $straight_count
    done

    [[ $debug -ge 3 ]] && echo "end of walk at $current_rim" > /dev/tty
}

weighted_walk () {
    local rimValue=$1
    local tempRim=()
    tempIFS=$IFS
    IFS='#' read -r -a tempRim <<< $(tr -d ' ' <<< $rimValue)
    IFS=$tempIFS
    local current_rim=${tempRim[2]}
    local straight_count=${tempRim[1]}
    local current_cost=${tempRim[0]}
    local current_tile=${current_rim:0:(-1)}
    local -n activeRim=sortedRim
    local nextRim=""

    [[ $debug -ge 2 ]] && echo "current: $rimValue" > /dev/tty

    if [[ ${#activeRim[@]} -eq 0 ]]; then
        echo "rim empty" > /dev/tty
        return
    fi

    if [[ "$current_tile" -eq $((total_length - 1)) ]]; then
        # found end, dont get new rim
        echo "path found with cost: $current_cost" > /dev/tty
        bestPathValue=$current_cost
        return
    else
        unset activeRim[$current_tile]
        local next_rims=( $(get_next_rims $current_rim $current_cost $straight_count) )
        local tempSlug=""
        for newRim in "${next_rims[@]}"; do
            tempIFS=$IFS
            IFS='#' read -r -a tempRim <<< $(tr -d ' ' <<< $newRim)
            IFS=$tempIFS
            tempSlug=${tempRim[2]}
            activeRim["${tempSlug:0:(-1)}"]=$newRim
        done
    fi


    local sorted_rims=()
    tempIFS=$IFS
    IFS=$'\n' sorted_rims=( $(sort -n <<< "${activeRim[*]}") )
    IFS=$tempIFS

    [[ $debug -ge 3 ]] && echo "active rims: ${sorted_rims[*]}" > /dev/tty
    [[ $debug -ge 4 ]] && echo "active rims positions: ${!activeRim[*]}" > /dev/tty

    nextRim=${sorted_rims[0]}

    [[ $debug -ge 2 ]] && echo "next: $nextRim"

    weighted_walk "$nextRim"
}

sortedRim[$start]="0#1#$start""v"

weighted_walk "0#1#$start""v"

# print_block node_weights
# echo "end weight: ${node_weights[$end]}"