

# XXX: why not using typeset -p ? hmmm should be checked

[public:assoc] SESSION

default_session_name="${default_session_name:-BASHSESSID}"
default_session_expiration="${default_session_expiration:-21600}"

Session::start(){
    [private] id="$(uuidgen)"

    if ! Session::check; then

        $sessionPath::$FUNCNAME "$id"

        COOKIE[$default_session_name]="${id}"
        Http::send::cookie "${default_session_name}=${id}; Max-Age=$default_session_expiration"

    else 
        Session::read 
    fi
}

Session::check(){

    $sessionPath::$FUNCNAME || return 1

    return 0
}

Session::destroy(){
    Http::send::cookie "${default_session_name}=delete; Max-Age=1"
    
    # redirect stderr to dev null if there is a failure, just to be sure :p
    $sessionPath::$FUNCNAME
}

Session::save(){
    $sessionPath::$FUNCNAME
}

Session::set(){
    [private] key="$1" 
    [private] value="${*:2}"

    [[ -z "$key" || -z "$value" ]] && return

    SESSION[$key]="$value"

    $sessionPath::$FUNCNAME
}

Session::unset(){
    [private] key="$1"

    [[ -z "$key" ]] && return

    unset SESSION[$key]

    $sessionPath::$FUNCNAME
}

Session::read(){
    $sessionPath::$FUNCNAME
}

Session::get(){
    [private] key="$1"

    [[ -z "$key" ]] && return

    $sessionPath::$FUNCNAME "$key"
}

alias session::start='Session::start'
alias session::check='Session::check'
alias session::destroy='Sesssion::destroy'
alias session::save='Session::save'
alias session::set='Session::set'
alias session::unset='Session::unset'
alias session::read='Session::read'
alias session::get='Session::get'

