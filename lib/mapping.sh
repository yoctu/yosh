#!/bin/bash
#source ./json.sh just a memo

Mapping::get::get_key() {
    string="$1"
    
    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]] # *1
    then
	rematchKey="${BASH_REMATCH[1]}"
    else
	echo "no match key"
    fi
}

Mapping::get::get_id() {
    string="$1"

    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]] # *1
    then
	rematchID="${BASH_REMATCH[2]}"
    else
	echo "no match id"
    fi 
}

Mapping::get::get_rematch() {
    string="$1"

    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]] # *1
    then
	rematch="${BASH_REMATCH[0]}"
    else
	echo "no match rematch"
    fi 
}

Mapping::check::check_match() {    
    [[ -z "$1" && -z "$2" ]] && echo "arg empty or null"

    string="$1"
    template="$2"
    declare -A arrayTmp

    if [[ "$template" =~ (.*)\{(.+)\}(.*) ]]
    then
	route="${BASH_REMATCH[1]}"
	id="${BASH_REMATCH[2]}"
	end="${BASH_REMATCH[3]}"
#	declare -p arrayTmp BASH_REMATCH
    else
	echo "bas template" && return
    fi
    if [[ "$string" =~ $route(.+)$end ]]
    then
	declare -p arrayTmp BASH_REMATCH
	arrayTmp["$id"]="${BASH_REMATCH[1]}"
	echo "test id ${BASH_REMATCH[2]}"
	#arrayTmp["$route"]="${BASH_REMATCH[2]}"
    else
	arrayTmp["$id"]=""
	#arrayTmp["$route"]=""
	echo "bad string"
    fi
    declare -p arrayTmp
}

Mapping::parsing::parse_route() {

    [[ -z "$1" && -z "$2" && -z "$3" ]] && echo "error arg is missing parse_route" && exit
    
    string="$1"
    template="$2"
    declare -A arrayTmp

    if Mapping::check::check_match $string $template;
    then
	arrayTmp[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"

	echo "key main BASH === ${BASH_REMATCH[1]}"
	echo "id main BASH  === ${BASH_REMATCH[2]}"
	printf '%s\n' "key ==  yoctu -> ${arrayTmp['yoctu']}"
    else
	arrayTmp['BASH_REMATCH[1]']=""
	echo "array[yoctu] = empty"
    fi
}

declare -A array['yoctu']="124"
declare -A route['yoctu']="/api/yoctu/{2345}"


Mapping::parsing::parse_route "/api/yoctu/{2345}" "/api/yoctu/{2345}" $array

alias mapping::get_key='Mapping::get::get_key'
alias mapping::get_id='Mapping::get::get_id'
alias mapping::get_rematch='Mapping::get::get_rematch'
alias mapping::check_match='Mapping::check::check_match'
alias mapping::parse_route='Mapping::parsing::parse_route'

#rematchKeys="${BASH_REMATCH[1]} == KEY"
#rematchIDs="${BASH_REMATCH[2]} == ID"


# SSS : add a fourth arg ? it would be a regex if the user want use a special string and template for example 
# SSS : If nothing is found it doesn't match
# SSS : Match all the integer in the string between {}
# SSS : Regex *1 match 2345 && yoctu
# SSS : The template would be /api/yoctu/23 without {}
