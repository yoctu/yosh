#!/bin/bash
#source ./json.sh just a memo

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

    [[ -z "$1" && -z "$2" ]] && echo "error arg is missing parse_route" && exit
    
    string="$1"
    template="$2"
    arrayZ=("$3")
    
    declare -A arrayTmp

    printf 'array in arg %s\n' "${arrayZ[@]}"

    #SSS : delete {} with the regex #memo

    if Mapping::check::check_match $string $template;
    then
	arrayTmp[${rematchKey}]=${id}
	#	arrayTmp[${id}]=${id}
	echo "test test ${arrayTmp[${rematchKey}]} && $rematchKey"

#	for key in "${!arrayTmp[${key]]}"; do
#	done
	
	#SSS : copy the array in arg in a local array and merge in the array in arg #memo
	
	#echo "parsing route == ${arrayTmp[${key}]}"
	#printf '%s\n' "key ==  yoctu -> ${arrayTmp['yoctu']}"
       
    else
	arrayTmp['BASH_REMATCH[1]']=""
	arrayTmp[${key}]=""
	#arrayTmp[${id}]=""
	echo "bad string" && exit
	echo "parsing route == array[yoctu] = empty"
		arrayTmp[${key}]="${id}"
	#arrayTmp[${id}]="${id}"
	# SSS : The if is just for get $key, i can do here, i just need to modif the regex
	#SSS : idk if the key is yoctu and i update de value ($id) related to yoctu
	#arrayTmp[${key}]=${id}
	
	#or if the key is the $id(2345) and i just update the key with the value from the $string 
	#arrayTmp[${id}]=${id}
    fi
}

declare -A array['yoctu']="124"
array['sofian']="12"

Mapping::parsing::parse_route "/api/yoctu/{2345}/foo" "/api/yoctu/{2345}/foo" "${array[@]}"

#Mapping::get::get_key "/api/yoctu/{5678}/foo"
#Mapping::get::get_id "/api/yoctu/{5678}/foo"
#Mapping::get::get_rematch "/api/yoctu/{5678}/foo"

alias mapping::get_key='Mapping::get::get_key'
alias mapping::get_id='Mapping::get::get_id'
alias mapping::get_rematch='Mapping::get::get_rematch'
alias mapping::check_match='Mapping::check::check_match'
alias mapping::parse_route='Mapping::parsing::parse_route'
alias mapping::check_template='Mapping::check::check_template'
alias mapping::check_string='Mapping::check::check_string'

#rematchKeys="${BASH_REMATCH[1]} == KEY"
#rematchIDs="${BASH_REMATCH[2]} == ID"
