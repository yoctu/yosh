#!/bin/bash

SELF="${BASH_SOURCE[0]##*/}"
NAME="${SELF%.sh}"

OPTS="c:r:g:svxEh"
USAGE="Usage: $SELF [$OPTS]"

HELP="
$USAGE

    Options:
        -c      Config File, should contain for example the POST Data for the request url
        -g      Request Method
        -s      simulate
        -v      set -v
        -x      set -x
        -e      set -ve
        -h      Help


"

_quit(){
    local retCode="$1" msg="${@:2}"

    echo -e "$msg"
    exit $retCode
}

while getopts "${OPTS}" arg; do
    case "${arg}" in
        c) _config_file="${OPTARG}"                                     ;;
        r) REQUEST_URI="/${OPTARG#/}"                                   ;;
        g) REQUEST_METHOD="$OPTARG"                                     ;;
        s) _run="echo"                                                  ;;
        v) set -v                                                       ;;
        x) set -x                                                       ;;
        e) set -ve                                                      ;;
        h) _quit 0 "$HELP"                                              ;;
        ?) _quit 1 "Invalid Argument: $USAGE"                           ;;
        *) _quit 1 "$USAGE"                                             ;;
    esac
done
shift $((OPTIND - 1))

[[ -z "$1" ]] && _quit 0 "$HELP"
REQUEST_URI="/$1"

REQUEST_METHOD="${REQUEST_METHOD:-CLI}"
[[ -z "$REQUEST_URI" ]] && _quit 2 "$HELP"

# Set DocumentRoot
DOCUMENT_ROOT="$(readlink -f $0)"
DOCUMENT_ROOT="${DOCUMENT_ROOT%/*}"

# use autoloader
source /usr/share/yosh/autoloader.sh

# Source the config file
[[ -f "$_config_file" ]] && source $_config_file 

# redirect stdout and stderr of function to file, to print after
tmpStdout="$(mktemp)"
tmpStderr="$(mktemp)"

# Clean TMP file on exit
trap "rm $tmpStdout; rm $tmpStderr" EXIT

# Save stdout and stderr to a file, to print out the both
route::check 1>$tmpStdout 2>$tmpStderr

# send data from route
[[ -s "$tmpStdout" ]] && cat $tmpStdout
[[ -s "$tmpStderr" ]] && cat $tmpStderr


