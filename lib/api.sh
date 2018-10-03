# some useful api functions 

declare -A API_MSG
API_MSG['error']="An Error occured while running request...."
API_MSG['not_found']="Request not found"
API_MSG['unauthorized']="No Authorization!"

declare -A API_RESPONSE

function api::search::function ()
{
    isFunction ${uri[1]} || api::send::not_found

    ${uri[1]}
}

function api::call::function ()
{
    isFunction $default_api_function || api::send::not_found

    $default_api_function
}

function api::send::fail ()
{
    http::send::status 500
    API_RESPONSE['msg']="${API_MSG['error']}"

    Json::create API_RESPONSE    
    exit
}

function api::send::unauthorized ()
{
    http::send::status 401
    API_RESPONSE['msg']="${API_MSG['unauthorized']}"

    Json::create API_RESPONSE
    exit
}

function api::send::not_found ()
{
    http::send::status 404
    API_RESPONSE['msg']="${API_MSG['not_found']}"

    Json::create API_RESPONSE
    exit
}

function api::send::post ()
{
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 201 

    Json::create $array
}

function api::send::put ()
{
    http::send::status 204    
}

function api::send::patch ()
{
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 202

    Json::create $array
}

function api::send::delete ()
{
    http::send::status 200
}

function api::send::get ()
{
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 200
}

