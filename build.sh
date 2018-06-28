#!/bin/bash

SELF="${BASH_SOURCE[0]##*/}"
NAME="${SELF%.sh}"

OPTS="svxEh"
USAGE="Usage: $SELF [$OPTS]"

HELP="
$USAGE

    Options:
        -s      simulate
        -v      set -v
        -x      set -x
        -e      set -ve
        -h      Help

"

function _quit ()
{
    local retCode="$1" msg="${@:2}"

    echo -e "$msg"
    exit $retCode
}

while getopts "${OPTS}" arg; do
    case "${arg}" in
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

oldPWD="$PWD"

sudo apt-get install -y apt-transport-https
wget -qO - https://ppa.yoctu.com/archive.key | sudo apt-key add -

sudo curl -o /bin/jq -O -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq

echo "deb https://ppa.yoctu.com/ all unstable" | sudo tee /etc/apt/sources.list
sudo apt-get update
sudo apt-get --nodeps install yoctu-client-scripts

#git log --first-parent --pretty="format:  * %s (%aN, %aI)"

