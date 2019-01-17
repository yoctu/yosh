#!/bin/bash

Mapping::get::getKey() {

    [private] string="$1"
    [private] rematchKey

    Type::variable::set $string $template || return 1
    
    if [[ "$string" =~ (.+)\{(.*)\}(.*) ]]; then
	rematchKey="${BASH_REMATCH[1]}"
	Type::variable::set $rematchKey || return 1
	echo "$rematchKey"
	return 0
    else
	return 1
}

Mapping::get::getId() {
    [private] string="$1"
    [private:string] rematchId

    Type::variable::set $string || return 1
    
    if [[ "$string" =~ (.+)\{(.*)\}(.*) ]]; then
	rematchId="${BASH_REMATCH[2]}"
	Type::variable::set $rematchId || return 1
	echo "$rematchId"
	return 0
    else
	return 1
}

Mapping::get::getRematch() {
    [private] string="$1"
    [string] rematch

    if [[ "$string" =~ (.+)\{(.*)\}(.*) ]]; then
        rematch="${BASH_REMATCH[0]}"
	Type::variable::set $rematch || return 1
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
    [private:assoc] array="$3"

    Type::variable::set $string $template || return 1
    Type::array::is::assoc "$3" || return 1
    
    if [[ "$template" =~ (.+)\{(.*)\}(.*) ]]; then
	route="${BASH_REMATCH[1]}"
        id="${BASH_REMATCH[2]}"
        end="${BASH_REMATCH[3]}"
	if [[ "$string" =~ $route(.+)$end ]]; then
	    array["$key"]="${BASH_REMATCH[1]}"
	    echo "$array"
	    return 0
	else
	    return 1
	fi
    else
	return 1
    fi
}


alias mapping::getKey='Mapping::get::getKey'
alias mapping::getId='Mapping::get::getId'
alias mapping::getRematch='Mapping::get::getRematch'
alias mapping::checkMatch='Mapping::check::checkMatch'

#je bouge ma voiture et je test
