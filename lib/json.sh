Json::create(){
    # Argument should be an array
    # to get a recursive json you can put in an array like this:
    # array['key':'subkey']="value"

    local -n array="$1"
    
    local -a tmparray
    local tmpvar

    for key in "${!array[@]}"; do
        IFS=":" read -a tmparray2 <<<"$key"
        count="0"
        for key_2 in ${tmparray2[@]}; do
            tmpvar+="{ \"$key_2\": "
            ((count++))
        done
        i="0"
        tmpvar+=" \"${array[$key]}\""
        until (( i == count )); do
            tmpvar+="}"
            ((i++))
        done
        tmparray+=("$tmpvar")
        unset tmpvar
    done

    local tmpFile="$(mktemp)"
    local tmpFile2="$(mktemp)"
    count="0"
    for entry in "${tmparray[@]}"; do
        if ! (( count )); then
            echo "$entry" >> $tmpFile
        else
            echo "$entry" > $tmpFile2

            output="$(jq -s -r '.[0] * .[1]' $tmpFile $tmpFile2)"
            echo "$output" > $tmpFile
        fi
        ((count++))
    done

    cat $tmpFile
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
    local parsed_sub="${sub// | keys_unsorted\[\]/}"
    local parsed_sub="${parsed_sub//keys_unsorted\[\]}"

    while read keys; do
        tmpCurKey="$parsed_sub.$keys"
        if echo "$json" | jq -r "$tmpCurKey | keys_unsorted[]" &>/dev/null; then
            Json::to::array::recursive "$json" "$parsed_sub.$keys | keys_unsorted[]"
        else
            tmpKey+="$keys"
            echo "${parsed_sub//./:}:$keys=$(echo "$json" | jq -r "$tmpCurKey")"
        fi
    done < <(echo "$json" | jq -r "$sub")
}

