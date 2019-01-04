#!/bin/bash

function fusion() {

    declare -A array1s="$1"
    declare -A array2s="$2"
    #declare -A fusion

    eval "declare -A fusion="${1#*=}
    echo "eval test === "
    declare -p fusion
#    echo "array1s ===  ${array1s[12]} ----- array2s === ${array2s[@]}"

    #fusion['id']+=( "${array1[@]}" "${array2[@]}") SSS : don't work
    #fusion[$id]=( "${array1[@]}" "${array2[@]}")
    #fusion+=(['id']="${array1[@]}" ['id']="${array2[@]}")
    #fusion="${array1s[@]}"
    #fusion=( "${array1s[@]}" "${array2s[@]}")
    echo "--------- ${fusion[id]}"
    for key in "${!fusion[@]}"
    do
	declare -p fusion
	echo "KEY == $key"
	echo "VALUE == ${fusion[$key]}"
	# name of fusion would be == arg2
    done
}

declare -A array1
declare -A array2

array1['id']="22"
array2['id']="45"

#fusion $array1 $array2
fusion "$(declare -p array1)" "$(declare -p array2)"
# SSS : array2 = array1 + array2 like key == 0 value == 22 ... but the key is not save
