#!/bin/bash

function myFunction
{
    eval "declare -A arrayFinal"="${1#*=}"

    for key in ${!arrayFinal[@]}; do
	echo -n "key == $key "
    done
    echo

    for value in ${arrayFinal[@]}; do
        echo -n "value == $value "
    done
    echo "array without boucle value == ${arrayFinal[@]}"
    echo "array without boucle key == ${!arrayFinal[@]}"
}

declare -A array=(['b']='12' ['a']='34' ['e']='17')

myFunction "$(declare -p array)"
