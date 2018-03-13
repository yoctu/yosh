# set default services

logger="${logger:-log-to-rsyslog}"
sessionPath="${sessionPath:-tmp}"
login_method="auth::request"
login_unauthorized="auth::unauthorized"
auth_encode="base64encode"
auth_decode="base64decode"

function base64encode ()
{
    echo "$@" | base64
}

function base64decode ()
{
    echo "$@" | base64 -d
}
