#!/bin/bash

# XXX: why not using typeset -p ? hmmm should be checked

declare -A SESSION

default_session_name="${default_session_name:-BASHSESSID}"
default_session_expiration="${default_session_expiration:-21600}"

function session::start ()
{
    local id="$(uuidgen)"

    if ! session::check
    then

        $sessionPath::$FUNCNAME "$id"

        COOKIE[$default_session_name]="${id}"
        http::send::cookie "${default_session_name}=${id}; Max-Age=$default_session_expiration"

    else 
        session::read 
    fi
}

function session::check ()
{

    $sessionPath::$FUNCNAME || return 1

    return 0
}

function session::destroy ()
{
    http::send::cookie "${default_session_name}=delete; Max-Age=1"
    
    # redirect stderr to dev null if there is a failure, just to be sure :p
    $sessionPath::$FUNCNAME
}

function session::save ()
{
    $sessionPath::$FUNCNAME
}

function session::set ()
{
    local key="$1" value="${@:2}"

    [[ -z "$key" || -z "$value" ]] && return

    SESSION[$key]="$value"

    $sessionPath::$FUNCNAME
}

function session::unset ()
{
    local key="$1"

    [[ -z "$key" ]] && return

    unset SESSION[$key]

    $sessionPath::$FUNCNAME
}

function session::read ()
{
    $sessionPath::$FUNCNAME
}

function session::get ()
{
    local key="$1"

    [[ -z "$key" ]] && return

    session::read

    echo "${SESSION[$key]}"
}

