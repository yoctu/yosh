#!/bin/bash

# Default is tmp 
function tmp::session::start ()
{

    local id="$1"

    touch /tmp/${id}
}

function tmp::session::check ()
{
    ! [[ -f "/tmp/${COOKIE[$default_session_name]}" ]] && return 1

    return 0
}

function tmp::session::destroy ()
{
    # redirect stderr to dev null if there is a failure, just to be sure :p
    rm "/tmp/${COOKIE[$default_session_name]}" 2>/dev/null
}

function tmp::session::save ()
{
    # save session array to a file
    typeset -p SESSION > /tmp/${COOKIE[$default_session_name]}
}

function tmp::session::set ()
{

    tmp::session::save

}

function tmp::session::unset ()
{

    tmp::session::save

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
