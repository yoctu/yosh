# a litte lib of type checking and data checker
type::function::exist(){
    # multiple function are accepted

    for _function in "$@"; do
        if [[ $(type -t "$_function") == "function" ]]; then
            return 0
        else
            return 1
        fi
    done
}

type::command::exist(){
    # multiple commands are accepted
    
    for _command in "$@"; do
        type "$_command" &>/dev/null
    done
}

type::array::contains(){
    # check if array contains value
    
    local key="$1"
    local -n array="$2"

    for value in "${array[@]}"; do
        [[ "$key" == "$value" ]] && return 0
    done

    return 1
}

type::variable::set(){
    # Check if varaibles are set

    for value in "$@"; do
        [[ -z "${!value}" ]] && return 1
    done

    return 0
}

