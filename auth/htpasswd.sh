#htpasswd file variable = htpasswd_file
# openssl passwd -apr1 -salt r31....

function htpasswd::auth::start ()
{
    [[ -z "$htpasswd_file" ]] && route::error

    if ! session::check
    then
            [[ -z "$HTTP_AUTHORIZATION" ]] && return 1
            user_pass="$(auth::decode "${HTTP_AUTHORIZATION/Basic /}")"
            if grep -o "${user_pass%%:*}:$(openssl passwd -apr1 -salt r31.... ${user_pass#*:})" $htpasswd_file &>/dev/null
            then
                session::start
                session::set USERNAME "${user_pass%%:*}"
                group="$(grep "${user_pass%%:*}:$(openssl passwd -apr1 -salt r31.... ${user_pass#*:}):" $htpasswd_file)"
                group=(${group//:/ })
                session::set GROUPNAME "${group[2]}"
            else
                return 1
            fi
    else
        session::read
    fi
}

function htpasswd::auth::check::rights ()
{

    session::read

    ! [[ "$auth_rights" == "${SESSION['GROUPNAME']}" ]] && { $unauthorized; return 1; }

    return 0
}
