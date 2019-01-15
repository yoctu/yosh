# To use this you should add the following rewrite rule in your vhost:
# RewriteEngine On
# RewriteCond %{REQUEST_FILENAME} -s [OR]
# RewriteCond %{REQUEST_FILENAME} -l [OR]
# RewriteCond %{REQUEST_FILENAME} -d
# RewriteRule ^.*$ - [NC,L]
# RewriteRule ^.*$ /main.sh [NC,L]

# shellcheck source=/var/tmp/yosh/tests/set_variables.sh

Route::check(){
    [private] uri
    [private:array] authArr
    [private] auths

    uri="${REQUEST_URI%%\?*}"
    uri="${uri#/}"
    uri="${uri:-/}"

    (( route_auditing )) && @audit "$application_name"

    Route::get::login

    auths="$(Route::get::auth)"

    IFS=',' read -r authArr <<<$auths

    for auth in "${auths[@]}"; do
        Auth::check "$auth" || continue
        # Does we really need this?
        Auth::check::rights "$auth" "$(Route::get::rights)" || continue
        break
    done

    ! [[ "$authSuccessful" ]] && { $unauthorized; return; }
    ! [[ "$rightsSuccessful" ]] && { $unauthorized; return; }

    # just be sure
    uri="${uri:-/}"

    if [[ "$REQUEST_METHOD" == "OPTIONS" ]]; then
        Http::send::options
        return
    fi

    # Try a centrelized way of doing this
    for router in ${ROUTERS[@]}; do
        $router "$uri" && break
    done

}

Route::simple(){
    [private] uri="$1"
    if [[ -z "${ROUTE["/$uri":"$REQUEST_METHOD"]}" ]]; then
        return 1
    else
        ${ROUTE["/$uri":"$REQUEST_METHOD"]}
    fi
}

Route::error(){
    Http::send::status 404
    echo "No Route Found!"
}

Route::get::auth(){
    for key in "${!AUTH[@]}"; do
        if [[ "/$uri:$REQUEST_METHOD" =~ $key ]]; then
            echo "${AUTH[$key]}"
            return
        fi
    done

    echo "${AUTH['/':$REQUEST_METHOD]:-none}"
}

Route::get::login(){
    for key in "${!LOGIN[@]}"; do
        if [[ "/$uri:$REQUEST_METHOD" =~ $key ]]; then
            login_method="${LOGIN[$key]}"
            return
        fi
    done

    login_method="${LOGIN['/':$REQUEST_METHOD]:-Auth::request}"

}

Route::get::rights(){
    for key in "${!RIGHTS[@]}"; do
        if [[ "/$uri:$REQUEST_METHOD" =~ $key ]]; then
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

ROUTERS+=("Route::simple")
