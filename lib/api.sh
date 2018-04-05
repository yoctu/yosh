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
