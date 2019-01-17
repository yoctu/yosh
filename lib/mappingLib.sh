#!/bin/bash

Mapping::get::getKey() {

    [private] string="$1"
    [private] rematchKey
    
    [[ -z "$string" ]] && exit
    
    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]]
    then
	rematchKey="${BASH_REMATCH[1]}"
	echo "$rematchKey"
	return 0
    else
	return 1
}

Mapping::get::getId() {
    [private] string="$1"
    [private:string] rematchId
    
    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]]
    then
	rematchId="${BASH_REMATCH[2]}"
	echo "$rematchId"
	return 0
    else
	return 1
}

Mapping::get::getRematch() {
    [private] string="$1"
    [string] rematch

    if [[ "$string" =~ ([a-zA-Z]*.)/\{(.+)\} ]]
    then
        rematch="${BASH_REMATCH[0]}"
	echo "$rematch"
        return 0
    else
        return 1
}


Mapping::check::checkMatch() {
    [private] string="$1"
    [private] template="$2"
    [private] route
    [private] id
    [private] end
    
    if [[ "$template" =~ (.+)\{(.*)\}(.*) ]]
    then
	route="${BASH_REMATCH[1]}"
        id="${BASH_REMATCH[2]}"
        end="${BASH_REMATCH[3]}"
	if [[ "$string" =~ $route(.+)$end ]]
	then
	    return 0
	else
	    return 1
	fi
    else
	return 1
    fi
}

Mapping::update::updateArray() {
    [private] string="$1"
    [private] template="$2"
    [private:asso] array="$3"
    [private] id
    [private] key
    
    [[ -z "$1" && -z "$2"]] && echo "error parse_route" && return 1
    Type::array::is::assoc "$3" || return 1

    #boucle for mutiple key
    if Mapping::check::checkMatch $string $template;
    then
	id=$(Mapping::get::getId $string)
	key=$(Mapping::get::getKey $string)
    
	array["${key}"]="${id}"
	echo "${array}"
	return 0
    else
	array["${key}"]=""
	return 1
    fi
}

alias mapping::getKey='Mapping::get::getKey'
alias mapping::getId='Mapping::get::getId'
alias mapping::getRematch='Mapping::get::getRematch'
alias mapping::checkMatch='Mapping::check::checkMatch'
alias mapping::parseRoute='Mapping::parse::parseRoute'
