#!/bin/bash

# main file

# use autoloader
source /usr/share/yosh/autoloader.sh

function _exit () {
    # Send header

    ! [[ -z "$access_control_allow_origin" ]] && http::send::header Access-Control-Allow-Origin "${access_control_allow_origin:-*}"
    http::send::out

    # send data from route
    [[ -s "$tmpStdout" ]] && cat $tmpStdout
    [[ -s "$tmpStderr" ]] && @error "$(cat $tmpStderr)"

    rm $tmpStdout
    rm $tmpStderr
}

# get GET and POST and COOKIE variable
http::read::get
http::read::post
http::read::cookie

# redirect stdout and stderr of function to file, to print after
tmpStdout="$(mktemp -p $TMPDIR)"
tmpStderr="$(mktemp -p $TMPDIR)"

# Clean TMP file on exit
trap '_exit' EXIT

# Save stdout and stderr to a file, to print out the both
# route::check 1>$tmpStdout 2>$tmpStderr
if type timeout &>/dev/null
then
#    timeout ${time_to_live:-30} $router 1>$tmpStdout 2>$tmpStderr
    $router 1>$tmpStdout 2>$tmpStderr
else
    $router 1>$tmpStdout 2>$tmpStderr
fi

# exit like a pro
# TRAP will now do the job
exit
