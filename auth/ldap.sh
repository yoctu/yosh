
function ldap::auth::start ()
{
    local user_pass user pass

    [[ -z "$ldap_host" || -z "$ldap_port" || -z "$ldap_organization_name" || "${#ldap_domain_component[@]}" != "2" ]] && { route::error; return 1; }

    if ! $sessionPath::session::check
    then
            [[ -z "$HTTP_AUTHORIZATION" ]] && return 1
            user_pass="$(echo "${HTTP_AUTHORIZATION/Basic /}" | base64 -d)"
            user="${user_pass%%:*}"
            pass="${user_pass#*:}"

            if ldapwhoami -h $ldap_host -p $ldap_port -D "cn=$user,o=$ldap_organization_name,dc=${ldap_domain_component[0]},dc=${ldap_domain_component[1]}" -x -w "$pass" &>/dev/null
            then
                $sessionPath::session::start
                $sessionPath::session::set USERNAME "${user_pass%%:*}"
            else
                return 1
            fi
    else
        $sessionPath::session::read
    fi
}

