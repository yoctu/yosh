rsyslog(){
    local level="$1" msg="${@:2}"

    logger -t $application_name -p $level $msg
}

rsyslog::log(){
    rsyslog "info" "$*"
}

rsyslog::error(){
    rsyslog "error" "$*"
}

rsyslog::deprecated(){
    rsyslog "notice" "$*"
}

rsyslog::audit(){
    rsyslog "info" "$*"
}
