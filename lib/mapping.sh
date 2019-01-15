#!/bin/bash
#source ./json.sh just a memo
#bash array parse the value in alphabet order (ascii)

Mapping::get::get_key() {
    string="$1"
    
    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]]
    then
	rematchKey="${BASH_REMATCH[1]}"
	echo "rematchKey -- getKey == ${rematchKey}"
    else
	echo "no match key"
    fi
}

Mapping::get::get_id() {
    string="$1"

    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]]
    then
	rematchID="${BASH_REMATCH[2]}"
	echo "rematchID -- getId == ${rematchID}"
    else
	echo "no match id"
    fi 
}

Mapping::get::get_rematch() {
    string="$1"

    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]]
    then
	rematch="${BASH_REMATCH[0]}"
	echo "rematchRematch -- getRematch == ${rematch}"
    else
	echo "no match rematch"
    fi 
}


Mapping::check::check_template() {

    string="$1"
    
    if [[ "$template" =~ (.+)\{(.*)\}(.*) ]]
    then
	route="${BASH_REMATCH[1]}"
	id="${BASH_REMATCH[2]}"
	end="${BASH_REMATCH[3]}"
	Mapping::get::get_key $string
    else
        echo "bad template" && exit
    fi 
}

Mapping::check::check_string() {
    if [[ "$string" =~ $route(.+)$end ]]
    then
	return
    else
	echo "bad string" && exit
    fi
}

#Mapping::update::update_array() {
#array
#string = value
#}

Mapping::check::check_match() {    
    [[ -z "$1" && -z "$2" ]] && echo "arg empty or null" && exit

    string="$1"
    template="$2"

    if Mapping::check::check_template $template $string;
    then
	Mapping::check::check_string $string
    else
	echo "error bad template or bad string" && exit
    fi
}

Mapping::parsing::parse_route() {

    [[ -z "$1" && -z "$2"  && -z "$3" ]] && echo "error arg is missing parse_route" && exit
    
    string="$1"
    template="$2"
    testArr=($3)
    
    #    local -n refArray=$3
    eval "declare -A arrayFinal"="${3#*=}"
    
    declare -A assoArraytest
#    assoArrayTest="${!3}"
    
    declare -A arrayTmp
    echo "arrayFinal key ===== ${!arrayFinal[@]}"
    echo "arrayFinal value ===== ${arrayFinal[@]}"
    echo "arrayFinal value yoctu ===== ${arrayFinal['yoctu']}"
    echo "arrayFinal value sofian ===== ${arrayFinal['sofian']}"

    #SSS : Vehbo tell me doesn't use eval, but i don't know how to do without, or the array need to be a global
    
    echo "******************************************************"
    echo "test print lenght from third arg ${#testArr[@]}"

    #SSS : delete {} with the regex #memo

    for lenght in "${#finalArray[@]}"; do
    
    if Mapping::check::check_match $string $template;
    then
	arrayTmp[${rematchKey}]=${id}
	#arrayTmp[${id}]=${id}

	for key in "${!arrayTmp[@]}"; do
	    echo "before modif value in arrayFinal ${arrayFinal[@]}"
	    if [[ "${!arrayTmp[${key}]}" == "${!arrayFinal[${key}]}" ]]
	    then
		echo "before modif value in arrayFinal ${arrayFinal[${rematchKey}]}"
		arrayFinal[${rematchKey}]="${arrayTmp[${rematchKey}]}"
		echo "after modif value in arrayFinal ${arrayFinal[${rematchKey}]}"
		echo "value of yoctu in arrayFinal ${arrayFinal['yoctu']}"
	    else
		echo "error parse_route *** if * * *"
	    fi
	done
    else
	arrayTmp[${key}]=""
	#arrayTmp[${id}]=""
	echo "bad string" && exit
	echo "parsing route == array[yoctu] = empty"
	arrayTmp[${key}]="${id}"
	#arrayTmp[${id}]="${id}"	

	#SSS : idk if the key is yoctu and i update de value ($id) related to yoctu
	#or if the key is the $id(2345) and i just update the key with the value from the $string 
    fi
    done
}

declare -A arrayAsso

arrayAsso=(['yoctu']='123' ['sofian']='456')

echo "first place arrayAsso ${!arrayAsso[@]}"

Mapping::parsing::parse_route "/api/yoctu/{12000}/foo" "/api/yoctu/{12000}/foo" "$(declare -p arrayAsso)"

alias mapping::get_key='Mapping::get::get_key'
alias mapping::get_id='Mapping::get::get_id'
alias mapping::get_rematch='Mapping::get::get_rematch'
alias mapping::check_match='Mapping::check::check_match'
alias mapping::parse_route='Mapping::parsing::parse_route'
alias mapping::check_template='Mapping::check::check_template'
alias mapping::check_string='Mapping::check::check_string'
