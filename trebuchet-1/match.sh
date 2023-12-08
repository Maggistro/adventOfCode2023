#!/bin/bash
matches3=("one" "two" "six")
matches4=("four" "five" "nine")
matches5=("three" "seven" "eight")
matches=("one" "two" "three" "four" "five" "six" "seven" "eight" "nine")
sum=0

get_index () {
    value=$1
    shift
    array=("$@")
    return_value=-1

    for i in "${!array[@]}"; do
        if [[ "${array[$i]}" = "${value}" ]]; then
            return_value=$i
        fi
    done

    echo $return_value
}

extract_numbers () {
    line=$1
    firstWord=-1
    lastWord=-1
    firstDigit=-1
    lastDigit=-1


    for (( c=0; c<${#line}; c++)); do

        #check digit
        if [[ ${line:$c:1} =~ ^[0-9]+$ ]]; then
            if [[ $firstDigit -eq -1 ]]; then
                firstDigit=${line:$c:1}
            fi
        #check matches
        else
            if [[ ${matches3[*]} =~ ${line:$pos:3} ]]; then
                if [[ $firstWord -eq -1 ]]; then
                    firstWord=${line:$pos:3}
                fi
            elif [[ ${matches4[*]} =~ ${line:$pos:4} ]]; then
                if [[ $firstWord -eq -1 ]]; then
                    firstWord=${line:$pos:4}
                fi
            elif [[ ${matches5[*]} =~ ${line:$pos:5} ]]; then
                if [[ $firstWord -eq -1 ]]; then
                    firstWord=${line:$pos:5}
                fi
            fi
        fi

        if [[ $firstDigit -ne -1 ]] || [[ $firstWord -ne -1 ]]; then
            break
        fi
    done

    for (( c=${#line}; c>0; c--)); do
        #check digit
        pos=$(($c - 1))
        if [[ $pos -lt 0 ]]; then
            continue
        fi
        if [[ ${line:$pos:1} =~ ^[0-9]+$ ]]; then
            if [[ $lastDigit -eq -1 ]]; then
                lastDigit=${line:$pos:1}
            fi
        fi
        if [[ $lastDigit -ne -1 ]] ; then
            break
        fi

        #check matches
        pos=$(($c - 3))
        if [[ $pos -lt 0 ]]; then
            continue
        fi
        if [[ ${matches3[*]} =~ ${line:$pos:3} ]]; then
            if [[ $lastWord -eq -1 ]]; then
                lastWord=${line:$pos:3}
            fi
        fi
        if [[ $lastWord -ne -1 ]]; then
            break
        fi

        pos=$(($c - 4))
        if [[ $pos -lt 0 ]]; then
            continue
        fi
        if [[ ${matches4[*]} =~ ${line:$pos:4} ]]; then
            if [[ $lastWord -eq -1 ]]; then
                lastWord=${line:$pos:4}
            fi
        fi
        if [[ $lastWord -ne -1 ]]; then
            break
        fi

        pos=$(($c - 5))
        if [[ $pos -lt 0 ]]; then
            continue
        fi
        if [[ ${matches5[*]} =~ ${line:$pos:5} ]]; then
            if [[ $lastWord -eq -1 ]]; then
                lastWord=${line:$pos:5}
            fi
        fi
        if [[ $lastWord -ne -1 ]]; then
            break
        fi
    done

    # echo $firstDigit
    # echo $lastDigit
    # echo $firstWord
    # echo $lastWord

    if [[ $firstWord -ne -1 ]]; then
        first=$(($(get_index "$firstWord" "${matches[@]}") + 1))
    fi

    if [[ $lastWord -ne -1 ]]; then
        second=$(($(get_index "$lastWord" "${matches[@]}") + 1))
    fi

    if [[ $firstDigit -ne -1 ]]; then
        first=$firstDigit
    fi

    if [[ $lastDigit -ne -1 ]]; then
        second=$lastDigit
    fi


    echo "$first$second"
}

while read -r line; do
    # value=$(echo $line | sed "s/[[:alpha:].-]//g")
    total=$(extract_numbers $line)
    echo $total
    # first=$(cut -c1-1 <<< $value)
    # second=$(rev <<< $value | cut -c1-1)
    sum=$(($sum + $total))
    # echo $first$second >> ./test
done < input

echo $sum

# line=7b
# digit=-1

# echo $(extract_numbers $line)

# if [[ ${matches3[*]} =~ ${line:0:3} ]]; then
#      if [[ $digit -eq -1 ]]; then
#         digit=${line:0:3}
#     fi
#     echo $digit
# fi

# if [[ ${line:0:1} =~ ^[0-9]+$ ]]; then
#     echo "found 2"
#check matches
# fi