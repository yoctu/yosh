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
    # Argument should be an array
    # to get a recursive json you can put in an array like this:
    # array['key':'subkey']="value"

    Type::array::is::assoc "$1" || return 1
    local -n array="$1"
 
    local -a tmparray
    local tmpvar
    local jsonarray
    local countingRun
    local count="0"
    local i="0"
    local tmpArrayVar

    for key in "${!array[@]}" "END"; do
        IFS=":" read -a tmparray2 <<<"$key"

        if [[ "$key" =~ .*:0$ ]]; then
            jsonarray=1
            tmpArrayVar="${array[$key]},"
        elif [[ "$jsonarray" == 1 && "$key" =~ .*:[1-9]+$ ]]; then
            tmpArrayVar+="${array[$key]},"
            countingRun="1"
        elif [[ "$jsonarray" == "1" && ! "$key" =~ .*:[0-9]+$ && "$key" == "END" ]]; then
            jsonarray="0"
            tmpvar+=$'$b | split(",")'
            until (( i == count )); do
                tmpvar+=" }"
                ((i++))
            done
            tmparray+=("$(jq -n -c -R --arg b "${tmpArrayVar%,}" " $tmpvar")")
            countingRun="0"
            tmpvar=""
            i=""
            count=""
            tmpArrayVar=""
        fi

        [[ "$key" == END ]] && break

        for key_2 in "${tmparray2[@]}"; do
            if [[ ! "$countingRun" == "1" ]] && [[ ! "$key_2" == "0" ]]; then
                tmpvar+="{ \"$key_2\" : "
                ((count++))
            fi
        done
        
        [[ "$jsonarray" == 1 ]] && continue

        tmpvar+='$b'
        until (( i == count )); do
            tmpvar+=" }"
            ((i++))
        done

        tmparray+=("$(echo "${array[$key]//[$'\t\r\n']}" | jq -c -R ". as \$b | $tmpvar")")
        count="0"
        tmpvar=""
        i="0"
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
    # Dzove855 2018-11-30: Dancer you're a good young padawan, nice jq function :D

    local -n array="$1" 
    local json="${*:2}"

    while read line; do
        [[ "$line" == @({|}) ]] && continue
        [[ "$line" =~ ^\"(.*)\":.* ]] && key="${BASH_REMATCH[1]}"
        [[ "$line" =~ .*:[[:space:]]\"(.*)\" ]] && value="${BASH_REMATCH[1]}"
        array[${key}]="${value}"
    done < <(echo "$json" | jq --arg delim ':' 'reduce (tostream|select(length==2)) as $i ({}; [$i[0][]|tostring] as $path_as_strings | ($path_as_strings|join($delim)) as $key | $i[1] as $value | .[$key] = $value )')
}

# to be more simple
alias json::to::array='Json::to::array'
alias json::create='Json::create'
alias json::create::simple='Json::create::simple'
alias array::to::json='Json::create'

