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

    if (( $auditing ))
    then

        for key in "${!GET[@]}"
        do
            _get_message+="| get_${key}=${GET[$key]} "
        done

        for key in "${!POST[@]}"
        do
            _post_message+="| post_${key}=${POST[$key]} "
        done

        log -m $default_auditing_method -l info "ROUTE=$uri $_get_message $_post_message"
    fi

    for key in "${!ROUTE[@]}"
    do
        arrKey=(${key//:/ })
        if [[ "/${uri}:${REQUEST_METHOD}" =~ ${arrKey[0]}:${arrKey[1]} ]]
        then
            auths=( ${arrKey[2]//,/ } )

            [[ -z "${arrKey[2]}" ]] && auths=( "none" )

            for auth in "${auths[@]}"
            do
                auth::check "$auth" || continue
                auth::check::rights "$auth" "${arrKey[3]}" || continue
                break
            done

            ! [[ "$authSuccessful" ]] && { $unauthorized; return; }
            ! [[ "$rightsSuccessful" ]] && { $unauthorized; return; }

            eval ${ROUTE["$key"]}
            return
        fi
    done

    for key in "${!ROUTE[@]}"
    do
        if [[ "$key" =~ "/:${REQUEST_METHOD}:"* ]]
        then

            arrKey=( ${key//:/ } )
            auths=( ${arrKey[2]//,/ } )

            [[ -z "${arrKey[2]}" ]] && auths=( "none" )

            for auth in "${auths[@]}"
            do
                auth::check "$auth" || continue
                auth::check::rights "$auth" "${arrKey[3]}" || continue
                break
            done

            ! [[ "$authSuccessful" ]] && { $unauthorized; return; }
            ! [[ "$rightsSuccessful" ]] && { $unauthorized; return; }

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

function route::create ()
{
    ! [[ $# -gt 1 ]] && return 

    local route_function="$1" route_location="$2" route_method="${3:-GET}" route_auth="${4:-none}" route_rights="${5:-none}"

    route_requete="ROUTE['$route_location':'$route_method':'$route_auth':'$route_rights']='$route_function'"

    # Where should i save the route?
    if [[ -f "${etc_conf_dir%/}/route.sh" ]] 
    then
        echo "$route_requete" >> ${etc_conf_dir%/}/route.sh
    else
        echo "$route_requete" >> ${DOCUMENT_ROOT%/}/../config/route.sh
    fi
}

