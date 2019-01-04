#!/bin/bash


function fusion() {
    array1="$1"
    array1="$2"

    fusion=( "${array1[@]}" "${array2[@]}")
    for key in "${!fusion[@]}"
    do
	echo "KEY == $key"
	echo "VALUE == ${fusion[$key]}"
    done
    
}

declare -A array1['id']="45"
declare -A array2['id']="56"

fusion $array1 $array2
