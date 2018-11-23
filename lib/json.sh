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
    # Argument should be an array
    # to get a recursive json you can put in an array like this:
    # array['key':'subkey']="value"

    Type::array::is::assoc "$1" || return 1
    local -n array="$1"
    
    local -a tmparray
    local tmpvar

    for key in "${!array[@]}"; do
        IFS=":" read -a tmparray2 <<<"$key"
        count="0"
        for key_2 in "${tmparray2[@]}"; do
            tmpvar+="{ \"$key_2\" : "
            ((count++))
        done
        i="0"
        tmpvar+='$b'
        until (( i == count )); do
            tmpvar+=" }"
            ((i++))
        done
        
        tmparray+=("$(echo "${array[$key]//[$'\t\r\n']}}" | jq -c -R ". as \$b | $tmpvar")")
        unset tmpvar
    done

    local tmpFile="$(mktemp)"
    local tmpFile2="$(mktemp)"
    for entry in "${tmparray[@]}"; do
        if ! [[ -s "$tmpFile" ]]; then
            echo "${entry}" >> $tmpFile
        else
            echo "${entry}" > $tmpFile2
            output="$(jq -c -Rs '(.|split("\n")[0]|fromjson) * (.|split("\n")[1]|fromjson)' "$tmpFile" "$tmpFile2")"
            echo "${output}" > $tmpFile
        fi
    done

    cat $tmpFile

    # Cleanup tmpfiles
    rm $tmpFile $tmpFile2
}

Json::to::array(){
    # Argmuent should be an array name and a json
    # the given array will contain the parsed json data
    
    local -n array="$1" 
    local json="${*:2}"

    while read line; do
        line="${line/:/}"
        array[${line%%=*}]="${line#*=}"
    done < <(Json::to::array::recursive "$json")
}

Json::to::array::recursive(){
    local json="${1}" sub="${2:-keys_unsorted[]}"
    local parsedSub="${sub// | keys_unsorted\[\]/}"
    parsedSub="${parsedSub//keys_unsorted\[\]}"

    while read keys; do
        tmpCurKey="$parsedSub.$keys"
        if echo "$json" | jq -r "$tmpCurKey | keys_unsorted[]" &>/dev/null; then
            Json::to::array::recursive "$json" "$parsedSub.$keys | keys_unsorted[]"
        else
            tmpKey+="$keys"
            echo "${parsedSub//./:}:$keys=$(echo "$json" | jq -r "$tmpCurKey")"
        fi
    done < <(echo "$json" | jq -r "$sub")
}

# to be more simple
alias json::to::array='Json::to::array'
alias json::create='Json::create'
alias json::create::simple='Json::create::simple'
alias array::to::json='Json::create'

