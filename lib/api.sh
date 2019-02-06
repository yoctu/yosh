# some useful api functions 

[public:assoc] API_MSG
    API_MSG['500']="An Error occured while running request...."
    API_MSG['404']="Request not found"
    API_MSG['401']="No Authorization!"

[public:assoc] API_RESPONSE

Api::router(){
    [private] url="$1"
    [private:array] uri
    IFS='/' read -a uri <<<$url

    [[ "$url" =~ ^api.* ]] || return

    Http::send::content-type "Application/json"

    if [[ -z "$default_api_function" ]]; then
        Api::search::function
    else
        Api::call::function
    fi
}

Api::search::function(){
    Type::function::exist "Api::${uri[1]}::${uri[2]}::${REQUEST_METHOD,,}" || Api::send::not_found

    Api::${uri[1]}::${uri[2]}::${REQUEST_METHOD,,}
}

Api::call::function(){
    Type::function::exist $default_api_function || Api::send::not_found

    $default_api_function
}

Api::send::fail(){
    Http::send::status 500
    API_RESPONSE['msg']="${API_MSG['500']}"

    Json::create API_RESPONSE    
    exit
}

Api::send::unauthorized(){
    Http::send::status 401
    API_RESPONSE['msg']="${API_MSG['401']}"

    Json::create API_RESPONSE
    exit
}

Api::send::not_found(){
    Http::send::status 404
    API_RESPONSE['msg']="${API_MSG['404']}"

    Json::create API_RESPONSE
    exit
}

Api::send::post(){
    [private] array="$1"

    [[ -z "$array" ]] && Api::send::fail

    Http::send::status 201 

    Json::create $array
}

Api::send::put(){
    [private] array="$1"

    Http::send::status 204

    Json::create $array
}

Api::send::patch(){
    [private] array="$1"

    [[ -z "$array" ]] && Api::send::fail

    Http::send::status 202

    Json::create $array
}

Api::send::delete(){
    [private] array="$1"
    Http::send::status 200

    Json::create $array
}

Api::send::get(){
    [private] array="$1"

    [[ -z "$array" ]] && Api::send::fail

    Http::send::status 200
    Json::create $array
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

ROUTERS+=("Api::router")

