Auth::check(){
    local auth_method="${1,,}"

    if [[ ! "$uri" == "$login_page" ]] && [[ -z "$auth_method" || "$auth_method" == "none" ]]; then
        authSuccessful="1" 
        return
    fi

    ${login_method^} "$auth_method" && authSuccessful=1
    Auth::start $auth_method
}

Auth::start(){
    local auth_method="${1,,}"

    [[ -z "$auth_method" || "$auth_method" == "none" ]] && { authSuccesful=1; return; }

    ${auth_method}::auth::start || return 1
#    Http::send::cookie "USERNAME=${SESSION['USERNAME']}; Max-Age=$default_session_expiration"

    authSuccessful="1"
}

Auth::check::rights(){
    local auth_method="${1,,}" auth_rights="${2,,}"

    [[ -z "$auth_rights" || "$auth_rights" == "none" ]] && { rightsSuccessful="1"; return; }

    if [[ ! "$auth_method" == "none" ]]; then
        ${auth_method}::auth::check::rights || return 1
    fi

    rightsSuccessful="1"
}

Auth::request(){
    if [[ -z "$HTTP_AUTHORIZATION" ]] && ! Session::check; then
        Http::send::header 'WWW-Authenticate' "Basic realm='$application_name'"
        Http::send::status 401
    fi
}

Auth::unauthorized(){
    Http::send::status 401
}

Auth::encode(){
    [[ -z "$1" ]] && return

    if [[ ! -z "$auth_encode" ]]; then
        $auth_encode "$*"
    else
        echo "$*"
    fi
}

Auth::decode(){
    [[ -z "$1" ]] && return

    if [[ ! -z "$auth_decode" ]]; then
        $auth_decode "$*"
    else
        echo "$@"  
    fi
}

Auth::custom::request(){
    unset auth_method
    if [[ -z "$HTTP_AUTHORIZATION" ]] && ! Session::check; then
        if [[ "$uri" != "$login_page" ]]; then
            uri="${uri%/}"
            Http::send::redirect temporary "${login_page}?requestUrl=${uri:-home}"
            return 1
        else
            if [[ -z "${POST['username']}" || -z "${POST['password']}" ]]; then
                return
            else
                HTTP_AUTHORIZATION="$(Auth::encode ${POST['username']}:${POST['password']})"
                # Get auth method from requesturi
                # set uri
                uri="${GET['requestUrl']:-home}"
                REQUEST_METHOD="GET"
                auth_method="$(Route::get::auth)"

                Auth::start $auth_method
                Http::send::redirect temporary "${GET['requestUrl']:-home}" 
            fi
        fi
    elif ! Session::check; then
        uri="${uri%/}"
        Http::send::redirect temporary "${login_page}?requestUrl=${uri:-home}"
        return 1
    fi
}

Auth::saml::request(){
    Auth::start $auth_method
}

Auth::api(){
    local auth_method="$1"
    $auth_method::Auth::start || return 1
}

# create alias to lowercase
alias auth::check='Auth::check'
alias auth::start='Auth::start'
alias auth::check::rights='Auth::check::rights'
alias auth::request='Auth::request'
alias auth::unauthorized='Auth::unauthorized'
alias auth::encode='Auth::encode'
alias auth::decode='Auth::decode'
alias auth::custom::request='Auth::custom::request'
alias auth::saml::request='Auth::saml::request'
alias auth::api='Auth::api'
