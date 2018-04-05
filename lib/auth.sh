function auth::source ()
{
    for auth_plugin in /usr/share/yosh/auth/*
    do
        source $auth_plugin
    done

    if ls -A ${DOCUMENT_ROOT%/}/../auth/*.sh &>/dev/null
    then
        for auth_plugin in ${DOCUMENT_ROOT%/}/../auth/*
        do
            source $auth_plugin
        done
    fi
}

function auth::check ()
{
    local auth_method="${1,,}"

    if [[ ! "$uri" == "$login_page" ]] && [[ -z "$auth_method" || "$auth_method" == "none" ]] 
    then
        authSuccessful="1" 
        return
    fi

    $login_method && authSuccessful=1
    auth::start $auth_method
}

function auth::start ()
{
    local auth_method="${1,,}"

    [[ -z "$auth_method" || "$auth_method" == "none" ]] && { authSuccesful=1; return; }

    auth::source

    ${auth_method}::auth::start || return 1
    http::send::cookie "USERNAME=${SESSION['USERNAME']}; Max-Age=$default_session_expiration"

    authSuccessful="1"
}

function auth::check::rights ()
{
    local auth_method="${1,,}" auth_rights="${2,,}"

    [[ -z "$auth_rights" || "$auth_rights" == "none" ]] && { rightsSuccessful="1"; return; }

    auth::source

    if [[ ! "$auth_method" == "none" ]]
    then
        ${auth_method}::auth::check::rights || return 1
    fi

    rightsSuccessful="1"
}

function auth::request ()
{
    if [[ -z "$HTTP_AUTHORIZATION" ]] && ! $sessionPath::session::check
    then
        http::send::header 'WWW-Authenticate' "Basic realm='$application_name'"
        http::send::status 401
    fi
}

function auth::unauthorized ()
{
    http::send::status 401
}

function auth::encode ()
{
    [[ -z "$1" ]] && return

    if [[ ! -z "$auth_encode" ]]
    then
        $auth_encode $@
    else
        echo "$@"
    fi
}

function auth::decode ()
{
    [[ -z "$1" ]] && return

    if [[ ! -z "$auth_decode" ]] 
    then
        $auth_decode $@
    else
        echo "$@"  
    fi
}

function auth::custom::request ()
{
    unset auth_method
    if [[ -z "$HTTP_AUTHORIZATION" ]] && ! $sessionPath::session::check
    then
        if [[ "$uri" != "$login_page" ]]
        then
            http::send::redirect temporary "${login_page}?requestUrl=${uri%/}"
        else
            if [[ -z "${POST['username']}" || -z "${POST['password']}" ]]
            then
                return
            else
                HTTP_AUTHORIZATION="$(auth::encode ${POST['username']}:${POST['password']})"
                # Get auth method from requesturi
                # set uri
                uri="${GET['requestUrl']}"
                REQUEST_METHOD="GET"
                auth_method="$(route::get::auth)"

                auth::start $auth_method
                http::send::redirect temporary "${GET['requestUrl']:-home}" 
            fi
        fi
    fi
}

function auth::saml::request ()
{
    auth::start $auth_method
}

