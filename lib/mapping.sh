Mapping::check::match() {
    [private] string="$1"
    [private] template="$2"
    [private] wayTo
    [private] id
    [private] end
    [private:map] array="$3"
    
    Type::variable::set string template || return 1
    Type::array::is::assoc "$3" || return 1
    
    if [[ "$template" =~ (.+)\{(.*)\}(.*) ]]; then
	wayTo="${BASH_REMATCH[1]}"
        id="${BASH_REMATCH[2]}"
        end="${BASH_REMATCH[3]}"
	Type::variable::set wayTo id end || return 1
	if [[ "$string" =~ $wayTo(.+)$end ]]; then
	    array["$id"]="${BASH_REMATCH[1]}"
	    printf '%s' "${array}"
	    return 0
	else
	    array["$id"]=""
	    printf '%s' "${array}"
	    return 0
	fi
    else
	return 1
    fi
}

alias mapping::match='Mapping::check::match'

#Lib Mapping; Take three arguments => string, template, associative array
