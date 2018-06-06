# variable authorization_key should be set
# auth_check="auth::api"
# auth_method="key::auth::start"

function key::auth::start ()
{
    [[ -z "$HTTP_AUTHORIZATION" ]] && return 1

    for key in "${authorization_key[@]}"
    do
        [[ "$HTTP_AUTHORIZATION" == "${key}" ]] && return 0
    done

    return 1 
}

