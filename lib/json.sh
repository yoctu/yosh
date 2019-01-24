#TODO: Cleaup :)

Json::create::simple(){
    [private] array="$1"

# Not need to be assoc
#    Type::array::is::assoc "$1" || return 1

    [[ -z "$array" ]] && return

    # redefine array name
    [private:map] array="$array"

    # this function generate an json from an array
    # jq using from FAQ mentioned by CharlesDuffy

    for key in "${!array[@]}"; do
        printf '%s\0%s\0' "$key" "${array[$key]}"
    done | jq -c -Rs -S '
                split("\u0000")
                | . as $a
                | reduce range(0; length/2) as $i 
                ({}; . + {($a[2*$i]): ($a[2*$i + 1]|fromjson? // .)})'
}

Json::create(){
    [private:map] array="$1"

    Type::array::is::assoc "$1"

    [private] key 
    [private] subKey 
    [private] jsonArray 
    [private] end
    [private:assoc] subKey

    for key in "${!array[@]}"; do
        IFS=':' read -ra subKeys <<< "$key"
        for subKey in "${subKeys[@]}"; do
            echo -n "{ \"$subKey\" :" 
            end+=" }"
        done
        echo -n "\"${array[$key]//\"/\\\"}\""
        echo "$end"
        unset end
    done | jq --slurp 'reduce .[] as $item ({}; . * $item)' | sed '/"[0-9]*":.*"$/{n;s/}/]/g}' | sed -zE 's/\{([^\n]*\n[^\n]*\"[0-9]*\"\:)/[\1/g' | sed 's/\"[0-9]*\"\://g' | jq -c -r .
}

Json::to::array(){
    # Argmuent should be an array name and a json
    # the given array will contain the parsed json data
    # Dzove855 2018-11-30: Dancer you're a good young padawan, nice jq function :D

    [private:map] array="$1" 
    [private] json="${*:2}"

    while read line; do
        [[ "$line" == @({|}) ]] && continue
        [[ "$line" =~ ^\"(.*)\":[[:space:]](.*)? ]] && { key="${BASH_REMATCH[1]}"; value="${BASH_REMATCH[2]}"; }
        value="${value%,}"
        value="${value%\"}"
        array[${key}]="${value#\"}"
    done < <(echo "$json" | jq --arg delim ':' 'reduce (tostream|select(length==2)) as $i ({}; [$i[0][]|tostring] as $path_as_strings | ($path_as_strings|join($delim)) as $key | $i[1] as $value | .[$key] = $value )')
}

# to be more simple

alias json::to::array='Json::to::array'
alias json::create='Json::create'
alias json::create::simple='Json::create::simple'
alias array::to::json='Json::create'

