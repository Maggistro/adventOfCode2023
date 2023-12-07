#!/bin/bash

get_intersection_length () {
    read -a quadratic <<< "$1"
    # this equals -c in formula
    local distance=$2

    # get quadratic square
    # => sqrt(b*b - 4ac)
    square=$(bc -l <<< "scale=5; sqrt((${quadratic[1]} * ${quadratic[1]}) + (4 * $distance * ${quadratic[0]}))")

    # round up first
    x_1=$(printf %.f $(bc -l <<< "scale=5; (-${quadratic[1]} + $square) / (2 * ${quadratic[0]}) + 1"))
    # round down second
    x_2=$(printf %.f $(bc -l <<< "scale=5; (-${quadratic[1]} - $square) / (2 * ${quadratic[0]})"))

    echo "$((x_2 - x_1))"
}

calculate_quadratic_function () {
    local start=(0 0)
    local endTime=$1
    local center=("$(bc -l <<< "scale=5; $endTime/2")" "$(bc -l <<< "scale=5; ($endTime - ($endTime / 2)) * ($endTime / 2)")")
    local end=($endTime 0)

    #start "0=a*0*0 + b*0 + c" always true
    # => c = 0 (dont care)

    #center "${center[1]}=a*${center[0]}*${center[0]} + b*${center[0]} + c"
    # => ${center[1]}=a*${center[0]}*${center[0]} + b*${center[0]}
    #end "0=a*${end[0]}*${end[0]} + b*${end[0]} + c"
    # => c = 0 - a*$endTime*$endTime + b*$endTime
    # => c = a*$endTime*$endTime + b*$endTime (start in end)
    # => 0 = a*$endTime*$endTime + b*$endTime
    # => b = -a*$endTime


    #center "${center[1]}=a*${center[0]}*${center[0]} + b*${center[0]}"
    # => ${center[1]}=a*${center[0]}*${center[0]} + b*${center[0]}" (end in center)
    # => ${center[1]}=a*${center[0]}*${center[0]} - a*$endTime*${center[0]}
    # => ${center[1]}=a*(${center[0]}*${center[0]} - $endTime*${center[0]})
    # => a=(${center[1]} / (${center[0]}*${center[0]} - $endTime*${center[0]}))
    a=$(bc -l <<< "scale=5; (${center[1]} / (${center[0]} * ${center[0]} - $endTime * ${center[0]}))")

    # result in end => b = -(${center[1]} / (${center[0]}*${center[0]} - $endTime*${center[0]}))*$endTime
    b=$(bc -l <<< "scale=5; -(${center[1]} / (${center[0]} * ${center[0]} - ($endTime * ${center[0]}))) * $endTime")

    echo "$a $b"
}

readarray -t race_data < race/input

IFS=':' read -ra time_line <<< ${race_data[0]}
IFS=':' read -ra distance_line <<< ${race_data[1]}
max_time=$(sed "s/ //g" <<< ${time_line[1]})
min_distance=$(sed "s/ //g" <<< ${distance_line[1]})

quadratic=$(calculate_quadratic_function $max_time)

echo $(get_intersection_length "$quadratic" $min_distance)
