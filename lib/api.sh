# some useful api functions 

function api::search::function ()
{
    isFunction ${uri[1]} || { http::send::status 404; echo "$errorMsg"; return; }

    ${uri[1]}
}

function api::call::function ()
{
    isFunction $default_api_function || { http::send::status 404; echo "$errorMsg"; return; }

    $default_api_function
}

function api::send::post ()
{
    local array="$1"

    [[ -z "$array" ]] && return 1

    http::send::status 201 

    array-to-json $array
}

function api::send::put ()
{
    local array="$1"

    [[ -z "$array" ]] && return 1

    
}
