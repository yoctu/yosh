#!/bin/bash

declare -A HEADERS_TO_SENT
HTTP_METHODS=( "POST" "GET" "DELETE" "PUT" "OPTIONS" )

function http::send::header ()
{
    local value="$1" key="${@:2}"

    [[ -z "$value" || -z "$key" ]] && return

    HEADERS_TO_SENT[$value]="$key"
}

function http::send::content-type ()
{
    local content_type="$1"    
    
    default_content_type=${default_content_type:-text/plain}

    HEADERS_TO_SENT["Content-type"]="${content_type:-$default_content_type}"
}

function http::send::status ()
{
    local code="$1"

    default_code="${default_code:-200}"

    declare -a STATUS_CODES
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

function http::send::cookie ()
{
    cookies+=("$1")
}

function http::send::redirect ()
{
    local redirectMethod="$1" redirectLocation="${@:2}" 

    permanent="301"
    temporary="302"

    [[ -z "$redirectMethod" || -z "$redirectLocation" ]] && return

    http::send::status ${!redirectMethod}
    HEADERS_TO_SENT["Location"]="$redirectLocation"
}

function http::send::out ()
{
    # XXX: Create lock to be sure, that the will not be sent twice
    local key

    # Send cookies
    for value in "${cookies[@]}"
    do
        echo "Set-Cookie: $value"
    done

    # Print out headers
    for key in "${!HEADERS_TO_SENT[@]}"
    do
        echo "$key: ${HEADERS_TO_SENT[$key]}"
    done

    # From HTTP RFC 2616 send newline before body
    echo 
}

function http::send::options ()
{
    local _methods="${HTTP_METHODS[@]}"
    http::send::header Allow "${_methods// /,}"
         
}

# set defaults
http::send::status
http::send::content-type

