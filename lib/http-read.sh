# Parse POST Data
Http::read::post(){
    local raw key oldIFS

    [[ -t 0 ]] && return

    # Get data from stdin
    read -n ${CONTENT_LENGTH:-1} raw <&0

    # set global POST env vars
    declare -Ag POST
    if [[ "${CONTENT_TYPE}" =~ application/x-www-form-urlencoded.* ]]
    then

        # Set IFS for array declaration
        IFS='&' read -a raw <<< "$raw"       
 
        # Save data as POST[KEY]=VALUE
        for key in "${raw[@]}"
        do
            trim key
            POST[$(urlencode -d "${key%%=*}")]="$(urlencode -d "${key#*=}")"
        done

    elif [[ "$CONTENT_TYPE" =~ application/json.* ]]
    then

        # get data raw in json key
        # Should we try to decode json to array?
        # Update 2018-11-18: json encode/decode is added
        Json::to::array POST "${raw}"
        #POST['json']="${raw}"

    else

        # get the rest as RAW key
        POST['raw']="${raw}"

    fi 

    unset key
}

# Parse Get Data
Http::read::get(){
    local key raw oldIFS
    
    declare -Ag GET

    # Set IFS for array declaration

    # get raw in array
    ! [[ -z "$QUERY_STRING" ]] && raw="$QUERY_STRING"

    [[ "$REQUEST_URI" =~ .*\?.* ]] && raw="${REQUEST_URI#*\?}"

    IFS='&' read -a raw <<< "$raw"

    # Save data as GET[KEY]=VALUE
    for key in "${raw[@]}"
    do
        trim key
        GET[$(urlencode -d "${key%%=*}")]="$(urlencode -d "${key#*=}")"
    done
    
    unset key
}

Http::read::cookie(){
    local key raw oldIFS

    declare -Ag COOKIE

    IFS=';' read -a raw <<< "$HTTP_COOKIE"

    for key in "${raw[@]}"
    do
        trim key
        COOKIE[${key%%=*}]="${key#*=}"
    done

    unset key
}

alias http::read::post='Http::read::post'
alias http::read::get='Http::read::get'
alias http::read::cookie='Http::read::cookie'
