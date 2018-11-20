# some useful api functions 

declare -A API_MSG
API_MSG['500']="An Error occured while running request...."
API_MSG['404']="Request not found"
API_MSG['401']="No Authorization!"

declare -A API_RESPONSE

Api::search::function(){

    isFunction "api::${uri[1]}::${uri[2]}::${REQUEST_METHOD,,}" || api::send::not_found

    api::${uri[1]}::${uri[2]}::${REQUEST_METHOD,,}
}

Api::call::function(){
    isFunction $default_api_function || api::send::not_found

    $default_api_function
}

Api::send::fail(){
    http::send::status 500
    API_RESPONSE['msg']="${API_MSG['500']}"

    Json::create API_RESPONSE    
    exit
}

Api::send::unauthorized(){
    http::send::status 401
    API_RESPONSE['msg']="${API_MSG['401']}"

    Json::create API_RESPONSE
    exit
}

Api::send::not_found(){
    http::send::status 404
    API_RESPONSE['msg']="${API_MSG['404']}"

    Json::create API_RESPONSE
    exit
}

Api::send::post(){
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 201 

    Json::create $array
}

Api::send::put(){
    http::send::status 204    
}

Api::send::patch(){
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 202

    Json::create $array
}

Api::send::delete(){
    http::send::status 200
}

Api::send::get(){
    local array="$1"

    [[ -z "$array" ]] && api::send::fail

    http::send::status 200
}

# apply function names lowercase
alias api::search::function='Api::search::function'
alias api::call::function='Api::call::function'
alias api::send::fail='Api::send::fail'
alias api::send::unauthorized='Api::send::unauthorized'
alias api::send::not_found='Api::send::not_found'
alias api::send::post='Api::send::post'
alias api::send::put='Api::send::put'
alias api::send::patch='Api::send::patch'
alias api::send::delete='Api::send::delete'
alias api::send::get='Api::send::get'
