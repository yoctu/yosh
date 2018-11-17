Json::set::prev(){
    [[ -z "$1" ]] && return 1

    _json_array="$1"

}

Json::set::array(){
    local _value

    [[ -z "$1" ]] && return 1
    [[ -z "$2" ]] && return 2

    typeset -n _json_tmp_array="$2"
    typeset -n _json_tmp_array_2="$1"

    for key in "${_json_tmp_array[@]}"
    do
        _value+="\"$key\","
    done

    _json_tmp_array_2[$2]="[${_value%,}]"

}

Json::set::next(){
    [[ -z "$1" ]] && return 1
    [[ -z "$2" ]] && return 2

    typeset -n _json_tmp_array="$1"
    _json_tmp_array[${2}]=$(json::create "$2")

}

Json::build::all(){
    Json::create "$_json_array"
}

Json::create(){
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

Json::to::array(){
    local -n array="$1" 
    local json="${*:2}"

    local tmpGlobKey
    local tmpKey

    while read line; do
        line="${line/:/}"
        array[${line%%=*}]="${line#*=}"
    done < <(Json::to::array::recursive "$json")

    #declare -p array
}

Json::to::array::recursive(){
    local json="${1}" sub="${2:-keys[]}"
    local tmpParKey="$tmpGlobKey"

    while read keys; do
        tmpCurKey="$tmpParKey.$keys"
        if echo "$json" | jq -r "$tmpCurKey | keys[]" &>/dev/null; then
            tmpGlobKey+=".$keys"
            Json::to::array::recursive "$json" "$tmpGlobKey | keys[]"
        else
            tmpKey+="$keys"
            echo "${tmpGlobKey//./:}:$keys=$(echo "$json" | jq -r "$tmpCurKey")"
            
        fi
    done < <(echo "$json" | jq -r "$sub")
}
