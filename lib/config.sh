

# you should not declare in a config, because we're good
[public:assoc] ROUTE
[public:assoc] RIGHTS
[public:assoc] AUTH
[public:assoc] LOGIN

# set default value for TMPDIR
if [[ -d "/dev/shm" ]]; then
    TMPDIR="/dev/shm"
else
    TMPDIR="/tmp"
fi

# XXX: Already in autoloader.sh
# Source all config from DOCUMENT_ROOT/config/
#for file in ${DOCUMENT_ROOT%/}/../config/*.sh; do
#    source $file
#done

#for file in ${etc_conf_dir%/}/*.sh; do
#    source $file
#done

# Just remove final slach :p
TMPDIR="${TMPDIR%/}"
