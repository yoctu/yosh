

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

# Source all config from DOCUMENT_ROOT/config/
for file in ${DOCUMENT_ROOT%/}/../config/*.sh
do
    source $file
done

if ls -A ${etc_conf_dir%/}/*.sh &>/dev/null
then
    for file in ${etc_conf_dir%/}/*.sh
    do
        source $file
    done
fi

# Just remove final slach :p
TMPDIR="${TMPDIR%/}"
