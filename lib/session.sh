#!/bin/bash

# XXX: why not using typeset -p ? hmmm should be checked

declare -A SESSION

default_session_name="${default_session_name:-BASHSESSID}"
default_session_expiration="${default_session_expiration:-21600}"

# Default is tmp 
function tmp::session::start ()
{
    local id="$(uuidgen)"

    if ! tmp::session::check
    then

        touch /tmp/${id}
    
        COOKIE[$default_session_name]="${id}"
        http::send::cookie "${default_session_name}=${id}; Max-Age=$default_session_expiration"

    else 
        tmp::session::read 
    fi
}

function tmp::session::check ()
{
    [[ -z "${COOKIE[$default_session_name]}" || "${COOKIE[$default_session_name]}" == "delete" ]] && return 1
    ! [[ -f "/tmp/${COOKIE[$default_session_name]}" ]] && return 1

    return 0
}

function tmp::session::destroy ()
{
    http::send::cookie "${default_session_name}=delete; Max-Age=1"
    
    # redirect stderr to dev null if there is a failure, just to be sure :p
    rm "/tmp/${COOKIE[$default_session_name]}" 2>/dev/null
}

function tmp::session::save ()
{
    local key
    # save session array to a file
    for key in "${!SESSION[@]}"
    do
        # always run, remove from file the old value if exist
        sed -i "/SESSION\['$key'\]=.*/d" /tmp/${COOKIE[$default_session_name]}
        echo "SESSION['$key']=\"${SESSION[$key]}\"" >> /tmp/${COOKIE[$default_session_name]}
    done
}

function tmp::session::set ()
{
    local key="$1" value="${@:2}"

    [[ -z "$key" || -z "$value" ]] && return

    SESSION[$key]="$value"

    tmp::session::save
}

function tmp::session::unset ()
{
    local key="$1"

    [[ -z "$key" ]] && return

    unset SESSION[$key]

    sed -i "/SESSION\['$key'\]=.*/d" /tmp/${COOKIE[$default_session_name]}
}

function tmp::session::read ()
{
    source /tmp/${COOKIE[$default_session_name]}
}

function tmp::session::get ()
{
    local key="$1"

    [[ -z "$key" ]] && return

    tmp::session::read

    echo "${SESSION[$key]}"
}
