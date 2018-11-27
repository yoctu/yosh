# a litte lib of type checking and data checker
Type::function::exist(){
    # multiple function are accepted

    for _function in "$@"; do
        if [[ $(type -t "$_function") == "function" ]]; then
            return 0
        else
            return 1
        fi
    done
}

Type::command::exist(){
    # multiple commands are accepted
    
    for _command in "$@"; do
        type "$_command" &>/dev/null
    done
}

Type::array::contains(){
    # check if array contains value
    
    local key="$1"
    local -n array="$2"

    for value in "${array[@]}"; do
        [[ "$key" == "$value" ]] && return 0
    done

    return 1
}

Type::array::is::assoc(){
    if declare -p "$1" &>/dev/null; then
        if [[ "$(declare -p "$1")" =~ "declare -A $1" ]]; then
            return 0
        else
            return 1
        fi
    fi
}

Type::variable::set(){
    # Check if varaibles are set

    for value in "$@"; do
        [[ -z "${!value}" ]] && return 1
    done

    return 0
}

Type::array::get::key(){
    # $1 is the key level, it should be like=machines:list
    # $2 is the array
    local level="${1%:}:"
    local -n array="$2"

    Type::variable::set level || return 1

    Type::array::is::assoc "$2" || return 1

    for key in "${!array[@]}";do
        [[ "$key" =~ ${level} ]] && { key="${key//$level}"; echo ${key%%:*}; }
    done | sort | uniq

}

Type::fusion::array::in::assoc(){
    local -n array="$1"
    local -n assoc="$2"
    local string="${3%:}"

    Type::variable::set string || return 1

    Type::array::is::assoc "$2" || return 1

    local count="0"
    for key in "${array[@]}"; do
        assoc[$string:$count]="$key"
        ((count++))
    done
}

alias type::function::exist='Type::function::exist'
alias type::command::exist='Type::command::exist'
alias type::array::contains='Type::array::contains'
alias type::array::is::assoc='Type::array::is::assoc'
alias type::variable::set='Type::variable::set'
alias type::array::get::key='Type::array::get::key'
alias type::fusion::array::in::assoc='Type::fusion::array::in::assoc'

