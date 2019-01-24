
#!/bin/bash

Mapping::get::key() {
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

Mapping::get::id() {
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

Mapping::get::rematch() {
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

Mapping::check::match() {
    [private] string="$1"
    [private] template="$2"
    [private] wayTo
    [private] id
    [private] end
    [private:assoc] array="$3"

    Type::variable::set $string $template || return 1
    Type::array::is::assoc "$3" || return 1
    
    if [[ "$template" =~ (.+)\{(.*)\}(.*) ]]; then #regex template in work
	wayTo="${BASH_REMATCH[1]}"
        id="${BASH_REMATCH[2]}"
        end="${BASH_REMATCH[3]}"
	Type::variable::set $wayTo $id $end || return 1
	if [[ "$string" =~ $wayTo(.+)$end ]]; then
	    array["$id"]="${BASH_REMATCH[1]}"
	    echo "$array"
	    return 0
	else
	    return 1
	fi
    else
	return 1
    fi
}

#template="apiyoctu{12000}45foo"
#string="apiyoctu1300045foo"
alias mapping::key='Mapping::get::key'
alias mapping::id='Mapping::get::id'
alias mapping::rematch='Mapping::get::rematch'
alias mapping::match='Mapping::check::match'
