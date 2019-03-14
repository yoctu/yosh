

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

Api::config::get(){
    [private] url="$1"
    
    IFS='/' read -a configArray <<<"$url"

    if [[ -z "${configArray[0]^^}" ]]; then
        Api::send::not_found
    fi

    [private:map] array="${configArray[0]^^}"

    if [[ -z "${array[@]}" ]]; then
        Api::send::not_found
    fi

    Api::send::get "${configArray[0]^^}"
}

