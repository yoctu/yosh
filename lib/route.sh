# To use this you should add the following rewrite rule in your vhost:
# RewriteEngine On
# RewriteCond %{REQUEST_FILENAME} -s [OR]
# RewriteCond %{REQUEST_FILENAME} -l [OR]
# RewriteCond %{REQUEST_FILENAME} -d
# RewriteRule ^.*$ - [NC,L]
# RewriteRule ^.*$ /main.sh [NC,L]

# shellcheck source=/var/tmp/yosh/tests/set_variables.sh

Route::api::mode(){
    local uri

    uri="${REQUEST_URI%%\?*}"
    uri="${uri#/}"
    uri=(${uri//\// })

    Http::send::content-type ${default_api_content_type:-application/json}

    # Api Mode
    # route_method="Route::api::mode"
    
    [[ "${uri[0]}" == "api" ]] || api::send::not_found

    Route::get::login

    auths="$(Route::get::auth)"
    auths=(${auths//,/ })

    (( route_auditing )) && @audit "$application_name"

    [[ -z "$auths" ]] && auths=("none")

    for auth in "${auths[@]}"
    do
        Auth::check "$auth" || continue
        # Does we really need this?
        Auth::check::rights "$auth" "$(Route::get::rights)" || continue
        break
    done

    ! [[ "$authSuccessful" ]] && api::send::unauthorized
    ! [[ "$rightsSuccessful" ]] && api::send::unauthorized

    if [[ -z "$api_command" ]]
    then
        [[ -f "${api_dir%/}/${uri[1]}" ]] || api::send::not_found
        source ${api_dir%/}/${uri[1]}
    else
        $api_command
    fi
}

Route::check(){
    # Default Mode
    # route_method="Route::check"
    local uri

    uri="${REQUEST_URI%%\?*}"
    uri="${uri#/}"
    uri="${uri:-/}"

    (( route_auditing )) && @audit "$application_name"

    Route::get::login

    auths="$(Route::get::auth)"
    auths=(${auths//,/ })

    for auth in "${auths[@]}"
    do
        Auth::check "$auth" || continue
        # Does we really need this?
        Auth::check::rights "$auth" "$(Route::get::rights)" || continue
        break
    done

    ! [[ "$authSuccessful" ]] && { $unauthorized; return; }
    ! [[ "$rightsSuccessful" ]] && { $unauthorized; return; }

    # just be sure
    uri="${uri:-/}"

    if [[ "$REQUEST_METHOD" == "OPTIONS" ]]
    then
        Http::send::options
        return
    fi

    if [[ ! -z "${ROUTE[/${uri#/}:$REQUEST_METHOD]}" ]]
    then
        eval ${ROUTE[/${uri#/}:$REQUEST_METHOD]}
    elif app::find &>/dev/null
    then
        app::source
    elif [[ -f "${html_dir}/${uri%.html}.html" ]]
    then
        html::print::out ${html_dir}/${uri%.html}.html
    elif [[ "$uri" =~ ^(css|js|img|fonts|player)/.* ]]
    then
        uri="${uri#*/}"
        ${BASH_REMATCH[1]}::print::out ${uri} || Route::error
    else        
        Route::error
    fi
}

Route::error(){
    Http::send::status 404
    echo "No Route Found!"
}

Route::get::auth(){
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

Route::get::login(){
    for key in "${!LOGIN[@]}"
    do
        if [[ "/$uri:$REQUEST_METHOD" =~ $key ]]
        then
            login_method="${LOGIN[$key]}"
            return
        fi
    done

    login_method="${LOGIN['/':$REQUEST_METHOD]:-Auth::request}"

}

Route::get::rights(){
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

alias route::api::mode='Route::api::mode'
alias route::check='Route::check'
alias route::error='Route::error'
alias route::get::auth='Route::get::auth'
alias route::get::login='Route::get::login'
alias route::get::rights='Route::get::rights'
router="Route::check"
