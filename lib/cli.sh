Cli::args(){
    echo ha
}

Cli::colorize(){
    local -A COLORS=(
        [FBLACK]="\[\033[30m\]"
        [FRED]="\[\033[31m\]"
        [FGREEN]="\[\033[32m\]"
        [FYELLOW]="\[\033[33m\]"
        [FBLUE]="\[\033[34m\]"
        [FMAGENTA]="\[\033[35m\]"
        [FCYAN]="\[\033[36m\]"
        [FWHITE]="\[\033[37m\]"
        [BBALCK]="\[\033[40m\]"
        [BRED]="\[\033[41m\]"
        [BGREEN]="\[\033[42m\]"
        [BYELLOW]="\[\033[43m\]"
        [BBLUE]="\[\033[44m\]"
        [BMAGENTA]="\[\033[45m\]"
        [BCYAN]="\[\033[46m\]"
        [BWHITE]="\[\033[47m\]"
    )
}
