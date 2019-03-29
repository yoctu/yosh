[public:assoc] CLI

Cli::router(){
    [private] route="$1"

    if Type::function::exist "${CLI["$route":'main']}"; then
        Cli::args "$route" "${argsArr[@]}"
        ${CLI["$route":'main']}
    else
        Cli::error "No command line found with $router"
    fi

}

Cli::args(){
    [private] route="$1"

    if Type::function::exist ${CLI["$route":"args"]}; then
        ${CLI["$route":'args']} "${argsArr[@]}"
    fi
}

Cli::help(){
    [private] route="$1"

    if Type::function::exist ${CLI["$route":'help']};then
        ${CLI["$route":'help']} ${*:2}
        exit
    else
        printf '%s\n' "$HELP"
        exit
    fi
}

Cli::colorize(){
    [private:assoc] COLORS=(
        [BLACK]='\033[0;30m'
        [RED]='\033[0;31m'
        [GREEN]='\033[0;32m'
        [YELLOW]='\033[0;33m'
        [BLUE]='\033[0;34m'
        [MAGENTA]='\033[0;35m'
        [CYAN]='\033[0;36m'
        [WHITE]='\033[0;37m'
    )
    
    printf '%s' "${COLORS[${1^^}]:-${COLORS[BLACK]}}"
}

Cli::list(){
    printf "$(Cli::colorize green)$(Type::array::get::key ".*" CLI)$(Cli::colorize white)\n"
}

Cli::error(){
    [private] msg="$*"

    printf "$(Cli::colorize red)$msg$(Cli::colorize white)\n" >&2
}

Cli::error::stacktrace(){
    [private:int] err=$?

    set +o xtrace

    [private] code="${1:-1}"

    Cli::error "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}. '${BASH_COMMAND}' exited with status $err"
    # Print out the stack trace described by $function_stack  

    if (( ${#FUNCNAME[@]} >> 2 )); then
        Cli::error "Call tree:"
        for ((i=1;i<${#FUNCNAME[@]}-1;i++)); do
            Cli::error " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
        done
    fi

    Cli::error "Exiting with status ${code}"
    exit $err
}

