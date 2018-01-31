#htpasswd file variable = htpasswd_file
# openssl passwd -apr1 -salt r31....

function htpasswd::auth::start ()
{
    [[ -z "$htpasswd_file" ]] && route::error

    if ! tmp::session::check
    then
        if [[ -z "$HTTP_AUTHORIZATION" ]]
        then
            auth::request
            return 1
        else
            user_pass="$(echo "${HTTP_AUTHORIZATION/Basic /}" | base64 -d)"
            if grep -o "${user_pass%%:*}:$(openssl passwd -apr1 -salt r31.... ${user_pass#*:})" $htpasswd_file &>/dev/null
            then
                tmp::session::start
                tmp::session::set USERNAME "${user_pass%%:*}"
                group="$(grep "${user_pass%%:*}:$(openssl passwd -apr1 -salt r31.... ${user_pass#*:}):" $htpasswd_file)"
                group=(${group//:/ })
                tmp::session::set GROUPNAME "${group[2]}"
            else
                auth::request
                return 1
            fi
        fi
    else
        tmp::session::read
    fi
}

function htpasswd::auth::check::rights ()
{

    tmp::session::read

    ! [[ "$auth_rights" == "${SESSION['GROUPNAME']}" ]] && { auth::unauthorized; return 1; }

    return 0
}
