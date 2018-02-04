#!/bin/bash

# Routes should be defined in a config file like:
#       ROUTE['/fuu']='SCRIPTNAME or function or shell script'
# or in a dir like DOCUMENT_ROOT/app with the name fuu.sh or fuu.bash or only fuu
# 
# this Script will automatically look for file with fuu or add extension .sh or .bash

# To use this you should add the folowing rewrite rule in your vhost:
# RewriteEngine On
# RewriteCond %{REQUEST_FILENAME} -s [OR]
# RewriteCond %{REQUEST_FILENAME} -l [OR]
# RewriteCond %{REQUEST_FILENAME} -d
# RewriteRule ^.*$ - [NC,L]
# RewriteRule ^.*$ /main.sh [NC,L]


function route::check ()
{
    local uri

    uri="${REQUEST_URI%\?*}"
    uri="${uri#/}"

    for key in "${!ROUTE[@]}"
    do
        arrKey=(${key//:/ })
        if [[ "/${uri}:${REQUEST_METHOD}" =~ ${arrKey[0]}:${arrKey[1]} ]]
        then
        
            auths=( ${arrKey[2]//,/ })

            for auth in "${auths[@]}"
            do
                auth::start "$auth" || continue
                auth::check::rights "$auth" "${arrKey[3]}" || continue
                break
            done

            ! [[ "$authSuccessful" ]] && return
            ! [[ "$rightsSuccessful" ]] && return

            eval ${ROUTE["$key"]}
            return
        fi
    done

    for key in "${!ROUTE[@]}"
    do
        if [[ "$key" =~ "/:${REQUEST_METHOD}" ]]
        then
            auths=( ${arrKey[2]//,/ })

            for auth in "${auths[@]}"
            do
                auth::start "$auth" || continue
                auth::check::rights "$auth" "${arrKey[3]}" || continue
                break
            done

            ! [[ "$authSuccessful" ]] && return
            ! [[ "$rightsSuccessful" ]] && return

            break
        fi
    done

    if app::find &>/dev/null
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

