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

alias type::function::exist='Type::function::exist'
alias type::command::exist='Type::command::exist'
alias type::array::contains='Type::array::contains'
alias type::array::is::assoc='Type::array::is::assoc'
alias type::variable::set='Type::variable::set'

