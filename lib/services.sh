# set default services

logger="${logger:-log-to-rsyslog}"
sessionPath="${sessionPath:-tmp}"
login_method="${login_method:-auth::request}"
login_unauthorized="${login_unauthorized:-auth::unauthorized}"
auth_encode="${auth_encode:-base64encode}"
auth_decode="${auth_decode:-base64decode}"

function base64encode ()
{
    echo "$@" | base64
}

function base64decode ()
{
    echo "$@" | base64 -d
}
