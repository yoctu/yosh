# variable authorization_key should be set
# login_method="auth::api"
# auth_method="key::auth::start"

function key::auth::start ()
{
    [[ -z "$HTTP_AUTHORIZATION" ]] && return 1
    if [[ "$HTTP_AUTHORIZATION" == "${authorization_key}" ]]
        return
    else
        return 1
    fi
    
}

