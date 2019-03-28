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

function _notify()
{
    echo -e "\n\n\n\n\n################################## $* #####################################\n\n\n\n\n" >&2
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

fileuuid="bck8:6497ccd4-8df3-46bf-aa3e-cfd6e748da69"
project="yosh"
IFS=/ read refs heads branch <<<$CPHP_GIT_REF

trap '_quit 2 "An Error occured while running script"' ERR

_notify "Install dependencies"
sudo apt-get update >&/dev/null ; sudo apt-get install -y apt-transport-https devscripts debianutils jq gridsite-clients ldap-utils uuid-runtime xmlsec1 xmlstarlet php &>/dev/null 
wget -qO - https://ppa.yoctu.com/archive.key | sudo apt-key add -

curl -s -o /tmp/jq -O -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x /tmp/jq
sudo mv /tmp/jq /usr/bin/jq

echo "deb https://ppa.yoctu.com/ all unstable" | sudo tee /etc/apt/sources.list 
sudo apt-get update &>/dev/null
cd /tmp

sudo apt-get install yoctu-scripts &>/dev/null
sudo apt-get install yosh &>/dev/null
sudo apt-get install yoctu-client-scripts &>/dev/null

_notify "Finished installing dependecies"

_notify "Fetch changelog"
cd -

filer-client.sh -U http://filer.test.flash-global.net -X get -u $fileuuid

mv /tmp/$project-changelog debian/changelog

_notify "Fetched changelog"

_notify "Setup Github"
sudo -s curl -o /bin/git-to-deb.sh -O -L https://ppa.yoctu.com/git-to-deb.sh
sudo chmod +x /bin/git-to-deb.sh

git config --global user.email "git@yoctu.com"
git config --global user.name "git"
_notify "Setup done"

_notify "Build package"
git-to-deb.sh -i >/dev/null

filer-client.sh -U http://filer.test.flash-global.net -c MISCELLANEOUS -n "$project-changelog" -f debian/changelog -C "need=Changelog file for $project" -m "text/plain" -X update -u $fileuuid
_notify "Build done"

_notify "Rsync to ppa"
mv ../$project*.deb ../$project.deb
export LC_FLASH_PROJECT_ID="$project"
export LC_FLASH_BRANCH=$CPHP_GIT_REF && scp -P2222 -o StrictHostKeyChecking=no -i ~/.ssh/automate.key ../$project.deb automate@term.test.flash-global.net:/tmp/${LC_FLASH_PROJECT_ID}.deb
_notify "Rsync done"

rm -rf debian

