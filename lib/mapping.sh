#!/bin/bash


Mapping::get_key() {
    string="$1"
    
    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]] # *1
    then
	rematchKey="${BASH_REMATCH[1]}"
    else
	echo "no match key"
    fi
    
}

Mapping::get_id() {
    string="$1"

    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]] # *1
    then
	rematchID="${BASH_REMATCH[2]}"
    else
	echo "no match id"
    fi 
}

Mapping::get_rematch() {
    string="$1"

    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]] # *1
    then
	rematch="${BASH_REMATCH[0]}"
    else
	echo "no match rematch"
    fi 
}

Mapping::check_pattern() {
    template="$1"

    [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]] && echo "bad template check_pattern" && exit
}

Mapping::parse_route() {

    [[ -z "$1" && -z "$2" && -z $"$3" ]] && echo "error arg is missing parse_route" && exit
    
    string="$1"
    template="$2"
    declare -A arrayTmp
    echo "dollar3 $3 array ${array['test']}"
    arrayTmp="$3"

   # if ! Mapping::check_pattern $template;
    #then
	#echo "bad template ok" && exit
    #fi

    if Mapping::get_key $string;
    then
	#rematchKeys="${BASH_REMATCH[1]}"
	#rematchIDs="${BASH_REMATCH[2]}"
	
	arrayTmp[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"

	echo "key main BASH === ${BASH_REMATCH[1]}"
	echo "id main BASH  === ${BASH_REMATCH[2]}"
	printf '%s\n' "key ==  yoctu -> ${arrayTmp['yoctu']}"

    else
	arrayTmp['BASH_REMATCH[1]']=""
	#rematchKeys['id']="BASH_REMATCH[2]"
    fi
}

declare -A array['yoctu']="124"
declare -A route['yoctu']="/api/yoctu/{2345}"

Mapping::parse_route "/api/yoctu/{2345}" "/api/yoctu/{12}" $array


# SSS : add a fourth arg ? it would be a regex if the user want use a special string and template for example 

# SSS : If nothing is found it doesn't match
# SSS : Match all the integer in the string between {}
# SSS : Regex *1 match 2345 && yoctu
# SSS : The template would be /api/yoctu/23 without {}
