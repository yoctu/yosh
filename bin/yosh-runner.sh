#!/bin/bash

SELF="${BASH_SOURCE[0]##*/}"
NAME="${SELF%.sh}"

OPTS="c:svxEh"
USAGE="Usage: $SELF [$OPTS]"

HELP="
$USAGE

    Options:
        -c      Config File, should contain for example the POST Data for the request url
        -s      simulate
        -v      set -v
        -x      set -x
        -e      set -ve
        -h      Help


"

source /usr/share/yosh/autoloader.sh

while getopts "${OPTS}" arg; do
    case "${arg}" in
        c) _config_file="${OPTARG}"                                     ;;
        s) _run="echo"                                                  ;;
        v) set -v                                                       ;;
        x) set -x                                                       ;;
        e) set -ve                                                      ;;
        h) Cli::help                                                    ;;
        ?) Cli::error "Invalid Argument: $USAGE"                        ;;
        *) Cli::error "$USAGE"                                          ;;
    esac
done
shift $((OPTIND - 1))

[[ -z "$1" ]] && Cli::help
REQUEST_URI="$1"

[[ -z "$REQUEST_URI" ]] && Cli::help

# Set DocumentRoot
DOCUMENT_ROOT="$(readlink -f $0)"
DOCUMENT_ROOT="${DOCUMENT_ROOT%/*}"

# Source the config file
[[ -f "$_config_file" ]] && source $_config_file 

# redirect stdout and stderr of function to file, to print after
tmpStdout="$(mktemp)"
tmpStderr="$(mktemp)"

# Clean TMP file on exit
trap "rm $tmpStdout; rm $tmpStderr" EXIT

if [[ "$REQUEST_URI" == "help" ]]; then
    Cli::help ${*:2}
elif [[ "$REQUEST_URI" == "list" ]];then
    Cli::list
else
    Cli::router $* 
fi

