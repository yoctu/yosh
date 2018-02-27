# logging lib
# This lib does logging and auditing.
# you can specify multiple commands
# Like auditing, logging etc...
# Everything is a different array

# Ex: 
#       LOGGING['log':'module']=""
#       LOGGING['log':'tag']=""
#       LOGGING['audit':'module']=""
#       LOGGING['audit':'tag']=""

#        OPTIONS:
#            -l  level
#            -t  Tag
#            -m  Method
#
#            Message is all after 

for file in /usr/share/yosh/logging/*
do
    source $file
done

# Source custom lib's
if ls -A ${DOCUMENT_ROOT%/}/../logging/* &>/dev/null
then
    for file in ${DOCUMENT_ROOT%/}/../logging/*
    do
        source $file
    done
fi

default_logging_method="${default_logging_method:-file}"

function log ()
{    
    local _level _tag _message _method

    # Hmmmm Should we do it with a different way?
    while getopts "l:m" arg; do
        case "${arg}" in
            l) _level="${OPTARG}"               ;;
            m) _method="${OPTARG}"              ;;
        esac
    done    
    shift $((OPTIND - 1))

    _message="$@"

    [[ -z "$_level" || -z "$_method" || -z "$_message" ]] && return

    _tag="${LOGGING[$_method:'tag']}"
    ${LOGGING[$_method:'method']}::log
}

