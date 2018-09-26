# some useful api functions 

declare -A API_MSG
API_MSG['error']="An Error occured while running request...."
API_MSG['not_found']="Request not found"

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

function api::send::fail ()
{
    http::send::status 500
    echo "{ \"error\": \"${API_MSG['error']}\"" 
    exit
}

function api::send::post ()
{
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 201 

    array-to-json $array
}

function api::send::put ()
{
#    local array="$1"

#    [[ -z "$array" ]] && return 1

    http::send::status 204    
}

function api::send::delete ()
{
#    local array="$1"

#    [[ -z 

    http::send::status 200
}

function apii::send::get ()
{
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 200
}
