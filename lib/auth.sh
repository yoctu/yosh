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

function auth::start ()
{
    local auth_method="${1,,}"

    [[ -z "$auth_method" || "$auth_method" == "none" ]] && { authSuccessful="1"; return; }

    auth::source

    $login_method

    ${auth_method}::auth::start || return 1
    http::send::cookie "USERNAME=${SESSION['USERNAME']}; Max-Age=$default_session_expiration"

    authSuccessful="1"
}

function auth::check::rights ()
{
    local auth_method="${1,,}" auth_rights="${2,,}"

    [[ -z "$auth_rights" || "$auth_rights" == "none" ]] && { rightsSuccessful="1"; return; }

    auth::source

    ${auth_method}::auth::check::rights || return 1

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
    if [[ -z "$HTTP_AUTHORIZATION" ]] && ! $sessionPath::session::check
    then
        if [[ "$uri" != "$login_page" ]]
        then
            http::send::redirect temporary "$HTTP_HOST/${login_page}?requestUrl=$uri"
        else
            if [[ -z "${POST['username']}" || -z "${POST['password']}" ]]
            then
                
            else

                auth::encode "${POST['username']}:${POST['password']}"

                { 
                    auth::start;
                    if [[ ! -z "${GET['requestUrl']}" ]]
                    then
                        http::send::redirect temporary "${HTTP_POST}${GET['requestUrl']}" ;
                    else
                        http::send::redirect temporary "${HTTP_POST}/"; 
                    fi 
                } || $login_unauthorized
            fi
        fi     
    fi
}

function auth::custom::unauthorized ()
{
    echo "haha"
}
