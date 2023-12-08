#!/bin/bash
readarray -t entries < input

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

map() {
    local incoming=$1
    local -n map=$2

    for (( index=0; index<${#map[@]}; index+=3 )); do
        local incoming_start=${map[$index]}
        local outgoing_start=${map[$index + 1]}
        local range=${map[$index + 2]}

    #    echo "$incoming $incoming_start $outgoing_start $range" > /dev/tty
        if [[ $((incoming - incoming_start)) -ge 0 ]] && [[ $((incoming_start + range - incoming)) -ge 0 ]]; then
        #    echo $((outgoing_start + incoming - incoming_start)) > /dev/tty
            echo $((outgoing_start + incoming - incoming_start))
            return
        fi
    done

    echo $incoming
}


activeMap=""
map=()
for entry in "${entries[@]}"; do
    if [[ $entry == "" ]]; then
        if [[ $activeMap == "seed_to_soil" ]]; then
            seed_to_soil=(${map[@]})
        elif [[ $activeMap == "soil_to_fertilizer" ]]; then
            soil_to_fertilizer=(${map[@]})
        elif [[ $activeMap == "fertilizer_to_water" ]]; then
            fertilizer_to_water=(${map[@]})
        elif [[ $activeMap == "water_to_light" ]]; then
            water_to_light=(${map[@]})
        elif [[ $activeMap == "light_to_temperature" ]]; then
            light_to_temperature=(${map[@]})
        elif [[ $activeMap == "temperature_to_humidity" ]]; then
            temperature_to_humidity=(${map[@]})
        elif [[ $activeMap == "humidity_to_location" ]]; then
            humidity_to_location=(${map[@]})
        fi
        activeMap=""
        map=()
        continue
    fi

    if [[ $entry =~ "seeds" ]]; then
        IFS=':' read -ra initial <<< $entry
        IFS=' ' read -ra seedParts <<< ${initial[1]}
        seeds+=(${seedParts[@]})
        continue
    fi

    if [[ ${entry:0:1} =~ ^[0-9]+$ ]]; then
        IFS=' ' read -ra mapping <<< $entry

        map+=(${mapping[1]})
        map+=(${mapping[0]})
        map+=(${mapping[2]})
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
for seed in "${seeds[@]}"; do
    soil=$(map $seed seed_to_soil)
    fertilizer=$(map $soil soil_to_fertilizer)
    water=$(map $fertilizer fertilizer_to_water)
    light=$(map $water water_to_light)
    temperature=$(map $light light_to_temperature)
    humidity=$(map $temperature temperature_to_humidity)
    locationTemp=$(map $humidity humidity_to_location)

    if [[ $location -gt $locationTemp ]]; then
        location=$locationTemp
    fi
done

echo $location