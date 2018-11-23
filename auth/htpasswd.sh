#htpasswd file variable = htpasswd_file
# openssl passwd -apr1 -salt r31....

function htpasswd::auth::start ()
{
    [[ -z "$htpasswd_file" ]] && Route::error

    if ! Session::check
    then
            [[ -z "$HTTP_AUTHORIZATION" ]] && return 1
            user_pass="$(Auth::decode "${HTTP_AUTHORIZATION/Basic /}")"
            if grep -o "${user_pass%%:*}:$(openssl passwd -apr1 -salt r31.... ${user_pass#*:})" $htpasswd_file &>/dev/null
            then
                Session::start
                Session::set USERNAME "${user_pass%%:*}"
                group="$(grep "${user_pass%%:*}:$(openssl passwd -apr1 -salt r31.... ${user_pass#*:}):" $htpasswd_file)"
                group=(${group//:/ })
                Session::set GROUPNAME "${group[2]}"
                Http::send::cookie "USERNAME=${SESSION['USERNAME']}; Max-Age=$default_session_expiration"
            else
                return 1
            fi
    else
        Session::read
    fi
}

function htpasswd::auth::check::rights ()
{

    Session::read

    ! [[ "$auth_rights" == "${SESSION['GROUPNAME']}" ]] && { $unauthorized; return 1; }

    return 0
}
