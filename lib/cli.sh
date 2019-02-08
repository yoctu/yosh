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

    Type::function::exist ${CLI["$route":"args"]} && ${CLI["$route":'args']} "${argsArr[@]}"
}

Cli::help(){
    [private] route="$1"

    Type::function::exist ${CLI["$route":'help']} && { ${CLI["$route":'help']} ${@:2}; return; }

    echo "$HELP" 
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
    
    printf "%s" "${COLORS[${1^^}]:-${COLORS[BLACK]}}"
}

Cli::list(){
    Type::array::get::key ".*" CLI
}

Cli::error(){
    [private] msg="$*"

    echo -e "$(Cli::colorize red)$msg$(Cli::colorize white)" >&2
}

