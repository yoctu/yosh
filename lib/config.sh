#!/bin/bash

# you should not declare in a config, because we're good
declare -A ROUTE
declare -A RIGHTS
declare -A AUTH
declare -A LOGIN

# set default value for TMPDIR
if [[ -d "/dev/shm" ]]
then
    TMPDIR="/dev/shm"
else
    TMPDIR="/tmp"
fi

# Just remove final slach :p
TMPDIR="${TMPDIR%/}"
