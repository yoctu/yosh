#!/bin/bash

SELF="${BASH_SOURCE[0]##*/}"
NAME="${SELF%.sh}"

OPTS="d:c:svxEh"
USAGE="Usage: $SELF [$OPTS]"

HELP="
$USAGE

    Options:
        -d      Document root
        -c      Config File, should contain for example the POST Data for the request url
        -s      simulate
        -v      set -v
        -x      set -x
        -e      set -ve
        -h      Help


"

while getopts "${OPTS}" arg; do
    case "${arg}" in
        d) export DOCUMENT_ROOT="$OPTARG"                               ;;
        c) _config_file="${OPTARG}"                                     ;;
        s) _run="echo"                                                  ;;
        v) set -v                                                       ;;
        x) set -x                                                       ;;
        e) set -ve                                                      ;;
        h) help="1"                                                     ;;
        ?) errorMSG="Invalid Argument: $USAGE"                          ;;
        *) errorMSG="$USAGE"                                            ;;
    esac
done
shift $((OPTIND - 1))

source /usr/share/yosh/autoloader.sh

(( help )) && Cli::help
[[ -z "$errorMSG" ]] || Cli::error "$errorMSG"

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

for key in "${@:2}"; do
    argsArr+=("${key}")
done

export argsArr

if [[ "$REQUEST_URI" == "help" ]]; then
    Cli::help ${*:2}
elif [[ "$REQUEST_URI" == "list" ]];then
    Cli::list
else
    Cli::router $*
fi

