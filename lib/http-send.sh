[public:assoc] HEADERS_TO_SENT
[public:array] HTTP_METHODS=( "POST" "GET" "DELETE" "PUT" "OPTIONS" )

Http::send::header (){
    [protected] value="$1" 
    [protected] key="${*:2}"

    [[ -z "$value" || -z "$key" ]] && return

    HEADERS_TO_SENT[$value]="$key"
}

Http::send::content-type(){
    local content_type="$1"    
    
    default_content_type=${default_content_type:-text/plain}

    HEADERS_TO_SENT["Content-type"]="${content_type:-$default_content_type}"
}

Http::send::status(){
    [private] code="$1"

    default_code="${default_code:-200}"

    [private:array] STATUS_CODES
        STATUS_CODES[200]="200 OK"
        STATUS_CODES[201]="201 Created"
        STATUS_CODES[301]="301 Moved Permanently"
        STATUS_CODES[302]="302 Found"
        STATUS_CODES[400]="400 Bad Request"
        STATUS_CODES[401]="401 Unauthorized"
        STATUS_CODES[403]="403 Forbidden"
        STATUS_CODES[404]="404 Not Found"
        STATUS_CODES[405]="405 Method Not Allowed"
        STATUS_CODES[500]="500 Internal Server Error"

    HEADERS_TO_SENT["Status"]="${STATUS_CODES[${code:-$default_code}]}"
}

Http::send::cookie(){
    cookies+=("$1")
}

Http::send::redirect(){
    [private] redirectMethod="$1" 
    [private] redirectLocation="${@:2}" 

    permanent="301"
    temporary="302"

    [[ -z "$redirectMethod" || -z "$redirectLocation" ]] && return

    Http::send::status ${!redirectMethod}
    HEADERS_TO_SENT["Location"]="$redirectLocation"
}

Http::send::out(){
    # XXX: Create lock to be sure, that the will not be sent twice

    # Send cookies
    for value in "${cookies[@]}"; do
        echo "Set-Cookie: $value"
    done

    # Print out headers
    for key in "${!HEADERS_TO_SENT[@]}"; do
        echo "$key: ${HEADERS_TO_SENT[$key]}"
    done

    # From HTTP RFC 2616 send newline before body
    echo 
}

Http::send::options(){
    [private] _methods="${HTTP_METHODS[@]}"
    Http::send::header Allow "${_methods// /,}"
         
}

alias http::send::header='Http::send::header'
alias http::send::content-type='Http::send::content-type'
alias http::send::status='Http::send::status'
alias http::send::cookue='Http::send::cookie'
alias http::send::redirect='Http::send::redirect'
alias http::send::out='Http::send::out'
alias http::send::options='Http::send::options'

# set defaults
Http::send::status
Http::send::content-type

