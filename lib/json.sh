#TODO: Cleaup :)

Json::create::simple(){
    local array="$1"

    Type::array::is::assoc "$1" || return 1

    [[ -z "$array" ]] && return

    # redefine array name
    typeset -n array="$array"

    # this function generate an json from an array
    # jq using from FAQ mentioned by CharlesDuffy

    for key in "${!array[@]}"
    do
            printf '%s\0%s\0' "$key" "${array[$key]}"
    done | jq -c -Rs -S '
                split("\u0000")
                | . as $a
                | reduce range(0; length/2) as $i 
                ({}; . + {($a[2*$i]): ($a[2*$i + 1]|fromjson? // .)})'
}

Json::create(){
    local -n array="$1"

    Type::array::is::assoc "$1"

    for key in "${!array[@]}"
    do
        IFS=':' read -ra subKeys <<< "$key"
        for subKey in "${subKeys[@]}"; do
            if [[ "$subKey" != "0" && "$jsonArray" != "1" ]]; then
                echo -n "{ \"$subKey\" :" 
                end+=" }"
            elif [[ "$subKey" == "0" ]]; then
                jsonArray="1"
                echo -n "["
                echo -n "\"${array[$key]}\","
            elif [[ "$subKey" =~ ^.*:[0-9]+$ ]] && [[ "$jsonArray" == "1" ]]; then
                echo -n "${${array[$key]}},"
            elif [[ ! "$subKey" =~ ^.*:[0-9]+$ ]] && [[ "$jsonArray" == "1" ]]; then
                unset jsonArray
                echo -n "]"
                echo "$end"
                unset end
                echo -n "{ \"$subKey\" :" 
            fi
        done
        [[ "$jsonArray" != "1" ]] && { echo -n "\"${array[$key]}\""; echo "$end"; unset end; }
    done #| jq --slurp 'reduce .[] as $item ({}; . * $item)'
}

Json::to::array(){
    # Argmuent should be an array name and a json
    # the given array will contain the parsed json data
    # Dzove855 2018-11-30: Dancer you're a good young padawan, nice jq function :D

    local -n array="$1" 
    local json="${*:2}"

    while read line; do
        [[ "$line" == @({|}) ]] && continue
        [[ "$line" =~ ^\"(.*)\":[[:space:]]\"(.*)\" ]] && { key="${BASH_REMATCH[1]}"; value="${BASH_REMATCH[2]}"; }
        array[${key}]="${value}"
    done < <(echo "$json" | jq --arg delim ':' 'reduce (tostream|select(length==2)) as $i ({}; [$i[0][]|tostring] as $path_as_strings | ($path_as_strings|join($delim)) as $key | $i[1] as $value | .[$key] = $value )')
}

# to be more simple
alias json::to::array='Json::to::array'
alias json::create='Json::create'
alias json::create::simple='Json::create::simple'
alias array::to::json='Json::create'

