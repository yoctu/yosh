# some useful api functions 

[public:assoc] API_MSG
    API_MSG['500']="An Error occured while running request...."
    API_MSG['404']="Request not found"
    API_MSG['401']="No Authorization!"
    API_MSG['400']="Server could not handle the request"

[public:assoc] API_RESPONSE
[public:assoc] API
    API['content-type']="Application/json"
    API['response':'Application/json']="Json::create"

Api::router::check(){
    [private] url="$1"
    [[ "$url" =~ ^api.* ]] || return

    router_run="Api::router"    
}

Api::router(){
    [private] url="$1"
    [private:array] uri
    IFS='/' read -a uri <<<$url

    [[ "$url" =~ ^api.* ]] || return

    Api::check::content_type
    Http::send::content-type "${API['content-type']}"

    if ! Api::search::function; then
        if ! [[ -z "$default_api_function" ]]; then
            Api::call::function
        else
            Api::send::not_found
        fi
    fi
}

Api::search::function(){
    if Type::function::exist "Api::${uri[1]}::${uri[2]}::${REQUEST_METHOD,,}"; then
        Api::${uri[1]}::${uri[2]}::${REQUEST_METHOD,,} "$(printf '%s/' "${uri[*]:3}")"
    elif Type::function::exist "Api::${uri[1]}::${REQUEST_METHOD,,}"; then
        Api::${uri[1]}::${REQUEST_METHOD,,} "$(printf '%s/' "${uri[*]:2}")"
    else
        return 1
    fi
}

Api::call::function(){
    Type::function::exist $default_api_function || return 1

    $default_api_function
}

Api::check::content_type(){
    if [[ "$CONTENT_TYPE" != "${API['content-type']}" ]]; then
        Http::send::status 400
        API_RESPONSE['msg']="${API_MSG['400']} : Content-type should be ${API['content-type']}"
        
        ${API['response':${API['content-type']}]} API_RESPONSE
        exit
    fi
}

Api::send::fail(){
    Http::send::status 500
    API_RESPONSE['msg']="${API_MSG['500']}"

    ${API['response':${API['content-type']}]} API_RESPONSE    
    exit
}

Api::send::unauthorized(){
    Http::send::status 401
    API_RESPONSE['msg']="${API_MSG['401']}"

    ${API['response':${API['content-type']}]} API_RESPONSE
    exit
}

Api::send::not_found(){
    Http::send::status 404
    API_RESPONSE['msg']="${API_MSG['404']}"

    ${API['response':${API['content-type']}]} API_RESPONSE
    exit
}

Api::send::post(){
    [private] array="$1"

    [[ -z "$array" ]] && Api::send::fail

    Http::send::status 201 

    ${API['response':${API['content-type']}]} $array
}

Api::send::put(){
    [private] array="$1"

    Http::send::status 204

    ${API['response':${API['content-type']}]} $array
}

Api::send::patch(){
    [private] array="$1"

    [[ -z "$array" ]] && Api::send::fail

    Http::send::status 202

    ${API['response':${API['content-type']}]} $array
}

Api::send::delete(){
    [private] array="$1"
    Http::send::status 200

    ${API['response':${API['content-type']}]} $array
}

Api::send::get(){
    [private] array="$1"

    [[ -z "$array" ]] && Api::send::fail

    Http::send::status 200
    ${API['response':${API['content-type']}]} $array
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
alias api::check::content_type='Api::check::content_type'

ROUTERS+=("Api::router::check")

