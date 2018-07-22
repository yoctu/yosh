function rsyslog ()
{
    local level="$1" msg="${@:2}"

    logger -t $application_name -p $level $msg
}

function rsyslog::log ()
{
    rsyslog "info" "$*"
}

function rsyslog::error ()
{
    rsyslog "error" "$*"
}

function rsyslog::deprecated ()
{
    rsyslog "notice" "$*"
}

function rsyslog::audit ()
{
    rsyslog "info" "$*"
}
