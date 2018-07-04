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

fileuuid="bck8:6497ccd4-8df3-46bf-aa3e-cfd6e748da69"
oldPWD="$PWD"

sudo apt-get update; sudo apt-get install -y apt-transport-https devscripts debianutils jq gridsite-clients
wget -qO - https://ppa.yoctu.com/archive.key | sudo apt-key add -

curl -o /tmp/jq -O -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x /tmp/jq
mv /tmp/jq /usr/bin/jq

echo "deb https://ppa.yoctu.com/ all unstable" | sudo tee /etc/apt/sources.list 
sudo apt-get update &>/dev/null
cd /tmp
#sudo apt-get download yoctu-client-scripts &>/dev/null
#sudo dpkg  --ignore-depends=jq -i yoctu-client-scripts*

sudo apt-get install yoctu-client-scripts

cd -

filer-client.sh -U http://filer.test.flash-global.net -X get -u $fileuuid

mv /tmp/yosh-changelog debian/changelog
sudo curl -o /bin/git-to-deb -O -L https://ppa.yoctu.com/git-to-deb 
sudo chmod +x /bin/git-to-deb

git config --global user.email "git@yoctu.com"
git config --global user.name "git"

git-to-deb -U build

filer-client.sh -U http://filer.test.flash-global.net -c MISCELLANEOUS -n "yosh-changelog" -f debian/changelog -C "need=Changelog file for yosh" -m "text/plain" -X update -u $fileuuid

mv ../yosh*.deb ../yosh.deb
export LC_FLASH_PROJECT_ID="yosh"
export LC_FLASH_BRANCH=$CPHP_GIT_REF && scp -P2222 -o StrictHostKeyChecking=no -i ~/.ssh/automate.key ../yosh.deb automate@term.test.flash-global.net:/tmp/${LC_FLASH_PROJECT_ID}.deb
 

rm -rf debian

#git log --first-parent --pretty="format:  * %s (%aN, %aI)"

