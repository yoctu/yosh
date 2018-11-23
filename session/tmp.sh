#!/bin/bash

# Default is tmp 
function tmp::Session::start ()
{

    local id="$1"

    touch $TMPDIR/${id}
}

function tmp::Session::check ()
{
    [[ -z "${COOKIE[$default_session_name]}" ]] && return 1
    ! [[ -f "$TMPDIR/${COOKIE[$default_session_name]}" ]] && return 1

    return 0
}

function tmp::Session::destroy ()
{
    # redirect stderr to dev null if there is a failure, just to be sure :p
    rm "$TMPDIR/${COOKIE[$default_session_name]}" 2>/dev/null
}

function tmp::Session::save ()
{
    local key
    # save session array to a file
    for key in "${!SESSION[@]}"
    do
        # always run, remove from file the old value if exist
        sed -i "/SESSION\['$key'\]=.*/d" $TMPDIR/${COOKIE[$default_session_name]}
        echo "SESSION['$key']=\"${SESSION[$key]}\"" >> $TMPDIR/${COOKIE[$default_session_name]}
    done
}

function tmp::Session::set ()
{

    tmp::Session::save

}

function tmp::Session::unset ()
{

    sed -i "/SESSION\['$key'\]=.*/d" $TMPDIR/${COOKIE[$default_session_name]}

}

function tmp::Session::read ()
{
    [[ -f "$TMPDIR/${COOKIE[$default_session_name]}" ]] && source $TMPDIR/${COOKIE[$default_session_name]}
}

function tmp::Session::get ()
{
    local key="$1"

    [[ -z "$key" ]] && return

    tmp::Session::read

    echo "${SESSION[$key]}"
}
