function @log ()
{
    # This function can be overwritten or create just an alias @log
    local _msg="$*"

    logger -t yosh "$_msg"
}

function @deprecated () 
{
    local _name="$*"
    
    @log "YOSH Depcrecated: $_name will no longer be available in the next Release!"
}

function @error ()
{
    local _msg="$*"
    
    @log "YOSH Error: $_msg"
}

function @audit ()
{
    local _msg="$*"

    @log "YOSH Audit: $_msg"
}
