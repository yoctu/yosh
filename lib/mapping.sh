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

    if [[ "$template" =~ (.+)\{(.*)\}(.*) ]]
    then
	route="${BASH_REMATCH[1]}"
	id="${BASH_REMATCH[2]}"
	end="${BASH_REMATCH[3]}"
	
	echo "check_match == array tmp"
	declare -p arrayTmp BASH_REMATCH
	echo "TEMPLATE check_match id == ${BASH_REMATCH[2]} && end == ${end}"
	echo "TEMPLATE check_match == after bash_rematch"
    else
	echo "bad template" && return
    fi
    if [[ "$string" =~ $route(.+)$end ]]
    then
	echo "STRING route == ${route} && id == ${id} && end == ${end}"
	arrayTmp["${id}"]="${BASH_REMATCH[1]}"
	echo "STRING id == ${BASH_REMATCH[1]}"
	echo "STRING id after arrayTmp stk == ${id} && arraytmp[id] == ${arrayTmp["$id"]}"
	#arrayTmp["$route"]="${BASH_REMATCH[2]}"
    else
	arrayTmp["$id"]=""
	#arrayTmp["$route"]=""
	echo "bad string" && exit
    fi
#    declare -p arrayTmp
}

Mapping::parsing::parse_route() {

    [[ -z "$1" && -z "$2" && -z "$3" ]] && echo "error arg is missing parse_route" && exit
    
    string="$1"
    template="$2"

    #SSS : copy the array in arg in a local array and merge in the array in arg
    #SSS : delete {} with the regex
    
    declare -A arrayTmp

    if Mapping::check::check_match $string $template;
    then
	arrayTmp[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"

#	echo "parsing route == key main BASH === ${BASH_REMATCH[1]}"
#	echo "parsing route == id main BASH  === ${BASH_REMATCH[2]}"
#	printf '%s\n' "key ==  yoctu -> ${arrayTmp['yoctu']}"
    else
	arrayTmp['BASH_REMATCH[1]']=""
	echo "parsing route == array[yoctu] = empty"
    fi
#    declare -p arrayTmp
}

declare -A array['yoctu']="124"

Mapping::parsing::parse_route "/api/yoctu/{2345}/" "/api/yoctu/{2345}/foo" $array

alias mapping::get_key='Mapping::get::get_key'
alias mapping::get_id='Mapping::get::get_id'
alias mapping::get_rematch='Mapping::get::get_rematch'
alias mapping::check_match='Mapping::check::check_match'
alias mapping::parse_route='Mapping::parsing::parse_route'

#rematchKeys="${BASH_REMATCH[1]} == KEY"
#rematchIDs="${BASH_REMATCH[2]} == ID"

# SSS : add a fourth arg ? it would be a regex
# SSS : If nothing is found it doesn't match
# SSS : Match all the integer in the string between {}
# SSS : Regex *1 match 2345 && yoctu
