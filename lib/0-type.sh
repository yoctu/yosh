# a litte lib of type checking and data checker

Type::function::exist(){
    # multiple function are accepted

    [[ -z "$*" ]] && return 1

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

    [[ -z "$*" ]] && return 1
    
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
        [[ "$key" =~ ^${level} ]] && { key="${key//$level}"; printf '%s\n' "${key%%:*}"; }
    done | sort | uniq

}

Type::fusion::array::in::assoc(){
    local -n array="$1"
    local -n assoc="$2"
    local string="${3%:}"

    Type::variable::set string || return 1

    Type::array::is::assoc "$2" || return 1

    local -i count="0"
    for key in "${array[@]}"; do
        assoc[$string:$count]="$key"
        ((count++))
    done
}

Type::array::fusion(){
    local -n srcArray="$1"
    local -n dstArray="$2"
    local regex="${3:-.*}"

    Type::array::is::assoc "$1" || return 1
    Type::array::is::assoc "$2" || return 1

    for key in "${!srcArray[@]}"; do
        [[ "$key" =~ $regex ]] && dstArray[$key]="${srcArray[$key]}"
    done
}

Type::variable::int(){
    local string="$1"
    [[ "${string#*=}" =~ ^[0-9]+$ ]] && return

    return 1
}

# Serialize Data (function, array, etc...)


alias type::function::exist='Type::function::exist'
alias type::command::exist='Type::command::exist'
alias type::array::contains='Type::array::contains'
alias type::array::is::assoc='Type::array::is::assoc'
alias type::variable::set='Type::variable::set'
alias type::array::get::key='Type::array::get::key'
alias type::fusion::array::in::assoc='Type::fusion::array::in::assoc'
alias type::array::fusion='Type::array::fusion'
alias \[int\]='local -i'
alias \[private\]='local'
alias \[public\]='declare -g'
alias \[map\]='local -n'
alias \[array\]='declare -a'
alias \[assoc\]='declare -A'
alias \[string\]='declare'
alias \[public:int\]='declare -gi'
alias \[private:int\]='local -i'
alias \[public:string\]='declare -g'
alias \[private:string\]='local'
alias \[public:map\]='declare -gn'
alias \[private:map\]='local -n'
alias \[public:array\]='declare -ga'
alias \[private:array\]='local -a'
alias \[public:assoc\]='declare -gA'
alias \[private:assoc\]='local -A'
alias \[const\]='declare -r'

