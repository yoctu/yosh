function log-to-rsyslog ()
{
    local level="$1" msg="${@:2}"

    logger -t $application_name -p $level $msg
}
