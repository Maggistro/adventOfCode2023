#!/bin/bash

calculate_function () {
    local endTime=$1
    local distance=$2

    # y=x*(D-x)
    # distance = x*(endTime -x)
    # 0 = -x*x + x*endTime - distance
    # => a=-1 b=endTime c=-distance
    # => x1 = (-b + sqrt(b*b - 4ac)) / 2a
    # => x2 = (-b - sqrt(b*b - 4ac)) / 2a
    square=$(bc -l <<< "scale=5; sqrt(($endTime * $endTime) - (4 * $distance))")
    x_1=$(printf %.f $(bc -l <<< "scale=5; (-$endTime + $square) / (-2)"))
    x_2=$(printf %.f $(bc -l <<< "scale=5; (-$endTime - $square) / (-2) + 1"))

    echo "$((x_2 - x_1))"
}

readarray -t race_data < race-6/input

IFS=':' read -ra time_line <<< ${race_data[0]}
IFS=':' read -ra distance_line <<< ${race_data[1]}
max_time=$(sed "s/ //g" <<< ${time_line[1]})
min_distance=$(sed "s/ //g" <<< ${distance_line[1]})

echo "$max_time $min_distance" > /dev/tty

echo $(calculate_function $max_time $min_distance)
