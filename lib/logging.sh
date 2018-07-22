declare -A LOG

# Config should be like this
# LOG['@log']="FUNCNAME"
# LOG['@deprecated']="FUNCNAME"
# LOG['@error']="FUNCNAME"
# LOG['@audit']="FUNCNAME"
#
# The function's should be in the func dir
# 
# Default Logging
LOG['@log']="rsyslog::log"
LOG['@deprecated']="rsyslog::deprecated"
LOG['@error']="rsyslog::error"
LOG['@audit']="rsyslog::audit"

function @log ()
{
    # This function can be overwritten or create just an alias @log
    local _msg="$*"

    ${LOG[$FUNCNAME]} "$_msg"
}

function @deprecated () 
{
    local _name="$*"
    
    ${LOG[$FUNCNAME]} "YOSH Depcrecated: $_name will no longer be available in the next Release!"
}

function @error ()
{
    local _msg="$*"
    
    ${LOG[$FUNCNAME]} "YOSH Error: $_msg"
}

function @audit ()
{
    local _msg="$*"

    ${LOG[$FUNCNAME]} "YOSH Audit: $_msg"
}

