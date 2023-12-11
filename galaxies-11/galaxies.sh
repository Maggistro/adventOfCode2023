#!/bin/bash
debug=${1:0}
readarray -t input < galaxies-11/input

declare -a galaxies=()
declare -a expanded_rows=()
declare -a expanded_cols=( $(for (( i=0; i<${#input[0]}; i++ )); do echo $i; done) )
galaxy_expansion=999999

manhattan_distance() {
    local x1=$1
    local y1=$2
    local x2=$3
    local y2=$4
    [[ $debug -ge 3 ]] && echo "x1 y1 x2 y2: $x1 $y1 $x2 $y2" > /dev/tty

    # basic manhatten distance
    x=$(( x2 - x1 ))
    x=${x#-}
    y=$(( y2 - y1 ))
    y=${y#-}

    [[ $debug -ge 3 ]] && echo "x,y: $x,$y" > /dev/tty

    # add expanded cols
    for exp_col in "${expanded_cols[@]}"; do
        if [[ $x1 -gt  $exp_col && $x2 -lt $exp_col ]]; then
            x=$(( x + galaxy_expansion ))
        elif [[ $x1 -lt $exp_col && $x2 -gt $exp_col ]]; then
            x=$(( x + galaxy_expansion ))
        fi
    done

    # add expanded cols
    for exp_row in "${expanded_rows[@]}"; do
        if [[ $y1 -gt  $exp_row && $y2 -lt $exp_row ]]; then
            y=$(( y + galaxy_expansion ))
        elif [[ $y1 -lt $exp_row && $y2 -gt $exp_row ]]; then
            y=$(( y + galaxy_expansion ))
        fi
    done

    echo $(( x + y ))
}


row=0
for (( row=0; row<${#input[@]}; row++ )); do
    line=${input[$row]}
    [[ $debug -ge 2 ]] && echo "Row $line"
    row_has_galaxy=0
    for ((col=0; col<${#line}; col++)); do
        if [[ ${line:$col:1} == "#" ]]; then
            [[ $debug -ge 2 ]] && echo "Galaxy is at row $row, column $col" > /dev/tty
            #x,y
            galaxies+=("$col#$row")
            row_has_galaxy=1
            unset "expanded_cols[$col]"
        fi
    done
    if [[ $row_has_galaxy -eq 0 ]]; then
        expanded_rows+=("$row")
    fi
done

[[ $debug -ge 1 ]] && echo "Galaxies: ${galaxies[*]}" > /dev/tty
[[ $debug -ge 1 ]] && echo "Expanded rows: ${expanded_rows[*]}" > /dev/tty
[[ $debug -ge 1 ]] && echo "Expanded cols: ${expanded_cols[*]}" > /dev/tty

# list of galaxies, double cost rows + cols. Let get distances
total_distance=0
for (( galaxy=0; galaxy<${#galaxies[@]}-1; galaxy++ )); do
    [[ $debug -ge 2 ]] && echo "Starting at: ${galaxies[$galaxy]}" > /dev/tty
    IFS='#' read -r -a coords <<< "${galaxies[$galaxy]}"

    for (( target_galaxy=galaxy+1; target_galaxy<${#galaxies[@]}; target_galaxy++ )); do
        if [[ $galaxy -eq $target_galaxy ]]; then
            continue
        fi

        [[ $debug -ge 3 ]] && echo " to ${galaxies[$target_galaxy]}" > /dev/tty
        IFS='#' read -r -a target_coords <<< "${galaxies[$target_galaxy]}"

        # get distance
        distance=$(manhattan_distance ${coords[0]} ${coords[1]} ${target_coords[0]} ${target_coords[1]})
        total_distance=$(( total_distance + distance ))
    done
done

echo $total_distance
