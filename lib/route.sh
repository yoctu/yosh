#!/bin/bash

# To use this you should add the following rewrite rule in your vhost:
# RewriteEngine On
# RewriteCond %{REQUEST_FILENAME} -s [OR]
# RewriteCond %{REQUEST_FILENAME} -l [OR]
# RewriteCond %{REQUEST_FILENAME} -d
# RewriteRule ^.*$ - [NC,L]
# RewriteRule ^.*$ /main.sh [NC,L]

# shellcheck source=/var/tmp/yosh/tests/set_variables.sh
function route::audit ()
{
    if (( route_auditing ))
    then

        for key in "${!GET[@]}"
        do
            _get_message+="| get_${key}=\"${GET[$key]}\" "
        done

        for key in "${!POST[@]}"
        do
            _post_message+="| post_${key}=\"${POST[$key]}\" "
        done

        log -m $default_auditing_method -l info "ROUTE=$uri $_get_message $_post_message"
    fi
}

function route::api::mode ()
{
    local errorMsg='{ "msg": "No Route Found!" }' unauthorizedMsg='{ "msg": "No Authorization!" }' uri

    uri="${REQUEST_URI%\?*}"
    uri="${uri#/}"
    uri=(${uri//\// })

    http::send::content-type ${default_api_content_type:-application/json}

    # Api Mode
    # route_method="route::api::mode"
    
    [[ "${uri[0]}" == "api" ]] || { http::send::status 404; echo "$errorMsg"; return; }

    route::get::login

    auths="$(route::get::auth)"
    auths=(${auths//,/ })

    (( route_auditing )) && @audit "$application_name"

    [[ -z "$auths" ]] && auths=("none")

    for auth in "${auths[@]}"
    do
        auth::check "$auth" || continue
        # Does we really need this?
        auth::check::rights "$auth" "$(route::get::rights)" || continue
        break
    done

    ! [[ "$authSuccessful" ]] && { http::send::status 401; echo "$unauthorizedMsg"; return; }
    ! [[ "$rightsSuccessful" ]] && { http::send::status 401; echo "$unauthorizedMsg"; return; }

    if [[ -z "$api_command" ]]
    then
        [[ -f "${api_dir%/}/${uri[1]}" ]] || { http::send::status 404; echo "$errorMsg"; return; }
        source ${api_dir%/}/${uri[1]}
    else
        $api_command
    fi
}

function route::check ()
{
    # Default Mode
    # route_method="route::check"
    local uri

    uri="${REQUEST_URI%\?*}"
    uri="${uri#/}"
    uri="${uri:-/}"

    (( route_auditing )) && @audit "$application_name"

    route::get::login

    auths="$(route::get::auth)"
    auths=(${auths//,/ })

    for auth in "${auths[@]}"
    do
        auth::check "$auth" || continue
        # Does we really need this?
        auth::check::rights "$auth" "$(route::get::rights)" || continue
        break
    done

    ! [[ "$authSuccessful" ]] && { $unauthorized; return; }
    ! [[ "$rightsSuccessful" ]] && { $unauthorized; return; }

    # just be sure
    uri="${uri:-/}"

    if [[ ! -z "${ROUTE[/${uri#/}:$REQUEST_METHOD]}" ]]
    then
        eval ${ROUTE[/${uri#/}:$REQUEST_METHOD]}
    elif app::find &>/dev/null
    then
        app::source
    elif [[ -f "${html_dir}/${uri%.html}.html" ]]
    then
        html::print::out ${html_dir}/${uri%.html}.html
    elif [[ "$uri" =~ ^(css|js|img|fonts)/.* ]]
    then
        uri="${uri#*/}"
        ${BASH_REMATCH[1]}::print::out ${uri} || route::error
    else        
        route::error
    fi
}

function route::error ()
{
    http::send::status 404
    echo "No Route Found!"
}

function route::get::auth ()
{
    for key in "${!AUTH[@]}"
    do
        if [[ "/$uri:$REQUEST_METHOD" =~ $key ]]
        then
            echo "${AUTH[$key]}"
            return
        fi
    done

    echo "${AUTH['/':$REQUEST_METHOD]:-none}"
}

function route::get::login ()
{
    for key in "${!LOGIN[@]}"
    do
        if [[ "/$uri:$REQUEST_METHOD" =~ $key ]]
        then
            login_method="${LOGIN[$key]}"
            return
        fi
    done

    login_method="${LOGIN['/':$REQUEST_METHOD]:-auth::request}"

}

function route::get::rights ()
{
    for key in "${!RIGHTS[@]}"
    do
        if [[ "/$uri:$REQUEST_METHOD" =~ $key ]]
        then
            echo "${RIGHTS[$key]}"
            return
        fi
    done

    echo "${RIGHTS['/':$REQUEST_METHOD]:-none}"
}

