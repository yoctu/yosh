# variable authorization_key should be set
# auth_check="auth::api"
# auth_method="key::auth::start"

function key::auth::start ()
{
    [[ -z "$HTTP_AUTHORIZATION" ]] && return 1

    [[ "$HTTP_AUTHORIZATION" == "${authorization_key}" ]] && return 0

    return 1 
}

