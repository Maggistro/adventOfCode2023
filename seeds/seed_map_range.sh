#!/bin/bash
readarray -t entries < seeds/input

# echo ${entries[@]}

# maps (start, end, range, start, end, range, start...)
seeds=()
seed_to_soil=()
soil_to_fertilizer=()
fertilizer_to_water=()
water_to_light=()
light_to_temperature=()
temperature_to_humidity=()
humidity_to_location=()

get_map () {
    local activeMap=$1

    if [[ $activeMap == "seed_to_soil" ]]; then
        echo "${seed_to_soil[@]}"
    elif [[ $activeMap == "soil_to_fertilizer" ]]; then
        echo "${soil_to_fertilizer[@]}"
    elif [[ $activeMap == "fertilizer_to_water" ]]; then
        echo "${fertilizer_to_water[@]}"
    elif [[ $activeMap == "water_to_light" ]]; then
        echo "${water_to_light[@]}"
    elif [[ $activeMap == "light_to_temperature" ]]; then
        echo "${light_to_temperature[@]}"
    elif [[ $activeMap == "temperature_to_humidity" ]]; then
        echo "${temperature_to_humidity[@]}"
    elif [[ $activeMap == "humidity_to_location" ]]; then
        echo "${humidity_to_location[@]}"
    fi
}


seed_ranges() {
    local map=()
    local map_name=$1
    read -a map <<< $(get_map "$map_name")
    shift
    local ranges=("$@")

    # echo "ranges ${ranges[*]}" > /dev/tty

    if [[ ${#ranges[@]} -eq 0 ]]; then
        return
    fi

    for (( rangeIndex=0; rangeIndex<${#ranges[@]}; rangeIndex+=2 )); do
        local new_ranges=( ${ranges[rangeIndex]} ${ranges[rangeIndex + 1]})

        # echo "new_ranges ${new_ranges[*]}" > /dev/tty
        for (( index=0; index<${#map[@]}; index+=3 )); do
            local left_split=()
            local right_split=()
            local center_split=()

            # get new possible start
            if [[ $((new_ranges[0] + new_ranges[1])) -lt ${map[index]} || $((map[index] + map[index + 2])) -lt ${new_ranges[0]} ]]; then
                # echo "continue ${map[index]} ${map[index + 2]}" > /dev/tty
                continue
            fi

            # split left
            if [[ ${new_ranges[0]} -lt ${map[index]} ]] && [[ $((new_ranges[0] + new_ranges[1])) -gt ${map[index]} ]]; then
                left_split=( ${new_ranges[0]} $((map[index] - new_ranges[0])) )
                new_ranges[0]=${map[index]}
                new_ranges[1]=$((map[index + 2] - (map[index] - left_split[0])))
            fi

            # split right
            if [[ ${new_ranges[0]} -lt $((map[index] + map[index + 2])) ]] && [[ $((map[index] + map[index + 2])) -lt $((new_ranges[0] + new_ranges[1])) ]]; then
                right_split=( $((map[index] + map[index + 2])) $((new_ranges[0] + new_ranges[1] - (map[index] + map[index + 2]))) )
                new_ranges[1]=$((map[index] + map[index + 2] - new_ranges[0]))
            fi

            # center split
            if [[ ${#left_split[@]} -gt 0 ]] && [[ ${#right_split[@]} -gt 0 ]]; then
                center_split=( ${map[index]} ${map[index + 2]} )
            elif [[ ${#left_split[@]} -gt 0 ]]; then
                center_split=( ${map[index]} ${new_ranges[1]} )
            elif [[ ${#right_split[@]} -gt 0 ]]; then
                center_split=( ${new_ranges[0]} ${new_ranges[1]} )
            else
                center_split=( ${new_ranges[@]} )
            fi

            # calculate mapped output center
            center_split[0]=$((map[index + 1] + new_ranges[0] - map[index]))
            center_split[1]=${new_ranges[1]}

            # call map_seeds with left_split and/or right_split
            if [[ ${#right_split[@]} -gt 0 ]]; then
                # echo "right ${map[index]} ${map[index + 2]} ${ranges[rangeIndex]} ${ranges[rangeIndex + 1]} ${new_ranges[*]} ${right_split[*]}" > /dev/tty
                read -a right_split <<< $(seed_ranges map_name "${right_split[@]}")
            fi

            if [[ ${#left_split[@]} -gt 0 ]]; then
                # echo "left ${map[index]} ${map[index + 2]} ${ranges[rangeIndex]} ${ranges[rangeIndex + 1]} ${new_ranges[*]} ${left_split[*]}" > /dev/tty
                read -a left_split <<< $(seed_ranges map_name "${left_split[@]}")
            fi

            # combine and return
            echo "${left_split[@]} ${right_split[@]} ${center_split[@]}"
            # echo "return ${ranges[*]}" > /dev/tty
            return
        done
    done

    echo "${ranges[@]}"
}

activeMap=""
mapping=()
for entry in "${entries[@]}"; do
    if [[ $entry == "" ]]; then
        if [[ $activeMap == "seed_to_soil" ]]; then
            seed_to_soil=(${mapping[@]})
        elif [[ $activeMap == "soil_to_fertilizer" ]]; then
            soil_to_fertilizer=(${mapping[@]})
        elif [[ $activeMap == "fertilizer_to_water" ]]; then
            fertilizer_to_water=(${mapping[@]})
        elif [[ $activeMap == "water_to_light" ]]; then
            water_to_light=(${mapping[@]})
        elif [[ $activeMap == "light_to_temperature" ]]; then
            light_to_temperature=(${mapping[@]})
        elif [[ $activeMap == "temperature_to_humidity" ]]; then
            temperature_to_humidity=(${mapping[@]})
        elif [[ $activeMap == "humidity_to_location" ]]; then
            humidity_to_location=(${mapping[@]})
        fi
        activeMap=""
        mapping=()
        continue
    fi

    if [[ $entry =~ "seeds" ]]; then
        IFS=':' read -ra initial <<< $entry
        IFS=' ' read -ra seedParts <<< ${initial[1]}
        seeds+=(${seedParts[@]})
        continue
    fi

    if [[ ${entry:0:1} =~ ^[0-9]+$ ]]; then
        IFS=' ' read -ra sub <<< $entry

        mapping+=(${sub[1]})
        mapping+=(${sub[0]})
        mapping+=(${sub[2]})
    else
        IFS=' ' read -ra mapSplit <<< $entry
        activeMap=$(sed s/-/_/g <<< ${mapSplit[0]})
    fi
done

# echo ${seeds[@]}
# echo ${seed_to_soil[@]}
# echo ${soil_to_fertilizer[@]}
# echo ${fertilizer_to_water[@]}
# echo ${water_to_light[@]}
# echo ${light_to_temperature[@]}
# echo ${temperature_to_humidity[@]}
# echo ${humidity_to_location[@]}

location=9223372036854775807
range=()
for (( seed=0; seed<${#seeds[@]}; seed+=2 )); do
    range=(${seeds[seed]} ${seeds[seed + 1]})
    # echo "soil" > /dev/tty
    read -a range <<< $(seed_ranges seed_to_soil "${range[*]}")
    # echo "fertilizer" > /dev/tty
    read -a range <<< $(seed_ranges soil_to_fertilizer "${range[@]}")
    # echo "water" > /dev/tty
    read -a range <<< $(seed_ranges fertilizer_to_water "${range[@]}")
    # echo "light" > /dev/tty
    read -a range <<< $(seed_ranges water_to_light "${range[@]}")
    # echo "temperature" > /dev/tty
    read -a range <<< $(seed_ranges light_to_temperature "${range[@]}")
    # echo "humidity" > /dev/tty
    read -a range <<< $(seed_ranges temperature_to_humidity "${range[@]}")
    # echo "location" > /dev/tty
    read -a range <<< $(seed_ranges humidity_to_location "${range[@]}")

    for (( index=0; index<${#range[@]}; index+=2 )); do
        if [[ $location -gt ${range[index]} ]]; then
            # echo "location $location replaced by ${range[index]}" > /dev/tty
            location=${range[index]}
        fi
    done
done

echo $location