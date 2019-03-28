# list all functions args and helps
# Doc file
# DOC['FUNCNAME':'args']=""
# DOC['FUNCNAME':'description']=""
# DOC['FUNCNAME':'output']=""

[public:array] DOC_ARGS
[public:assoc] DOC
DOC['config':'func':'docpath']="${YOSH_PATH}/doc/funcname.sh"

Doc::create::func(){
    [private] title="$1"
    [private] funcname="${2//:/|}"
    [private] msg="${@:3}"

    DOC[func:"$funcname":$title]="$msg"
}

Doc::list::args(){
    for key in "$@"; do
        DOC_ARGS+=("${key//:/|}")
    done
}

Doc::list::function(){
    [private:array] toDisplay
    source ${DOC['config':'func':'docpath']}

    if [[ -z "${DOC_ARGS}" ]]; then
        while read key; do
            if ! [[ -z "${DOC['func':"$key":'description']}" ]]; then
                toDisplay+=("$key")
            fi
        done < <(Type::array::get::key 'func:' DOC)
    else
        for key in "${DOC_ARGS[@]}"; do
            if ! [[ -z "${DOC[func:"$key":'description']}" ]]; then
                toDisplay+=("$key")
            fi
        done
        
    fi

    for key in "${toDisplay[@]}"; do
                
        printf "$(Cli::colorize green)%s$(Cli::colorize white)\n" "${key//|/:}"
        printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Description:" 
        printf "        %s\n" "${DOC[func:$key:'description']}"

        if ! [[ -z "${DOC['func':$key:'args']}" ]]; then
            printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Arguments:" 
            printf "        %s\n" "${DOC[func:$key:'args']}"
        fi

        if ! [[ -z "${DOC['func':$key:'output']}" ]]; then
            printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Output:" 
            printf "        %s\n" "${DOC[func:$key:'output']}"
        fi

        if ! [[ -z "${DOC['func':$key:'example']}" ]]; then
            printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Example:" 
            printf "        %s\n" "${DOC[func:$key:'example']}"

        fi
        printf '\n\n'
            
    done
}

alias Doc::create::func::args='Doc::create::func args'
alias Doc::create::func::description='Doc::create::func description'
alias Doc::create::func::output='Doc::create::func output'
alias Doc::create::func::example='Doc::create::func example'

CLI['doc-func':'args']="Doc::list::args"
CLI['doc-func':'main']="Doc::list::function"
