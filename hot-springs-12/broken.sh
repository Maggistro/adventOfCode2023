#!/bin/bash
debug=${1:0}
readarray -t lines < hot-springs-12/miniinput

getAllMaskVariations () {
    local groupDefinition=$1
    local groupSize=$2
    local max_pos=-1

    local -A hitList=()
    for (( i=0; i<${#groupDefinition[@]} - $groupSize; i++ )); do
        if [[ $i -eq $max_pos ]]; then
            break
        fi
        hit=0
        for (( pos=0; pos<$groupSize; pos++)); do
            case ${groupDefinition[i]} in
                '#')
                    hit=$((hit + 1))
                    ;;
            esac
        done
        hitList[$i]=$hit

        #natural hit, all ? must be 0
        if [[ $hit -eq $groupSize ]]; then
            echo 1
            return
        fi

        #clear hitlist to always include #
        if [[ $hit -ge 1 ]] && [[ $max_pos -eq -1 ]]; then
            hitList=()
            max_pos=$((pos + 2*groupSize - 2))
        fi
    done

    echo ${#hitList[@]}
}

createMaskList () {
    local -n possible_masks=$1
    IFS=',' read -r -a temp_groups <<< "$2"
    local inputLength=$3

    mask=''

    for group in "${groups[@]}"; do
        for (( i=0; i<${#group}; i++ )); do
            mask+='1'
        done
        mask+='0'
    done

    getAllMaskVariations $mask $inputLength possible_masks
}

checkMatch () {
    local maskPart=$1
    local groupSize=$2

    for (( one=0; one<${#groupSize[@]}; one++ )); do
        if [[ ${maskPart[$one]} == '.' ]]; then
            echo 0
            return
        fi
    done

    if [[ ${maskPart:$groupSize:1} == '#' ]]; then
        echo 0
        return
    fi

    echo 1
}

matchGroupCount () {
    local mask=$1
    shift
    local groups=( "$@" )

    local group_number=0
    local variant=0

    for (( pos=0; pos<${#mask}; pos++ )); do
        size=${groups[$group_number]}
        if [[ $(checkMatch ${mask:$pos:$size} ${groups[$group_number]}) -eq 1 ]]; then
            newVariants=$(matchGroupCount ${mask:$((pos+1))} "${groups[@]:1}")
            variant=$((newVariants + variant))
        fi
    done

    echo $variant
}

variations=0
for line in "${lines[@]}"; do
    IFS=' ' read -r -a maskAndGroups <<< "${line}"

    variations=$((variations + $(matchGroupCount ${maskAndGroups[0]} ${maskAndGroups[1]})))
done

echo $variations
