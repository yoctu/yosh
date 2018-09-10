function json::set::parent() 
{
    [[ -z "$1" ]] && return 1

    typeset -n _json_array="$1"

}

function json::set::array()
{
    local _value

    [[ -z "$1" ]] && return 1
    [[ -z "$2" ]] && return 1
    [[ -z "$3" ]] && return 1

    typeset -n _json_tmp_array="$3"

    for key in "${_json_tmp_array}"
    do
        _value+="\"$key\","
    done

    eval ${1}[$2]="[${_value%,}]"

    unset _json_tmp_array
}

function json::set::child()
{
    [[ -z "$1" ]] && return 1
    [[ -z "$2" ]] && return 1

    eval ${1}[${2}]="$(json::create "$2")"
}

function json::build::family()
{
    json::create "_json_array"
}

function json::create()
{
    # this function generate an json from an array
    # jq using from FAQ mentioned by CharlesDuffy

    typeset -n _json_tmp_array="$1"

    for key in "${!_json_tmp_array[@]}"
    do
        printf '%s\0%s\0' "$key" "${_json_tmp_array[$key]}"
    done | jq -c -Rs -S '
                split("\u0000")
                | . as $a
                | reduce range(0; length/2) as $i 
                ({}; . + {($a[2*$i]): ($a[2*$i + 1]|fromjson? // .)})'    

    unset _json_tmp_array
}
