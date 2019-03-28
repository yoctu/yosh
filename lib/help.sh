# list all functions args and helps
# Array HELP_LIST is set in 0-type.sh
# HELP_LIST['FUNCNAME':'args']=""
# HELP_LIST['FUNCNAME':'description']=""
# HELP_LIST['FUNCNAME':'output']=""

[public:array] HELP_ARGS

Help::list::args(){
    HELP_ARGS+=($@)
}

Help::list::function(){

    declare -p HELP_LIST
    if [[ -z "${HELP_ARGS}" ]]; then
        while read key; do
            if ! [[ -z "${HELP_LIST[$key:'description']}" ]]; then
                printf "$(Cli::colorize green)%s$(Cli::colorize white)\n" "$key"
                printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Description:" 
                printf "        %s\n" "${HELP_LIST[$key:'description']}"

                if ! [[ -z "${HELP_LIST[$key:'args']}" ]]; then
                    printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Arguments:" 
                    printf "        %s\n" "${HELP_LIST[$key:'args']}"
                fi

                if ! [[ -z "${HELP_LIST[$key:'output']}" ]]; then
                    printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Output:" 
                    printf "        %s\n" "${HELP_LIST[$key:'output']}"
                fi
            fi
        done < <(Type::array::get::key ".*" HELP_LIST)
    else
        for key in "${HELP_ARGS[@]}"; do
            if ! [[ -z "${HELP_LIST[$key:'description']}" ]]; then
                printf "$(Cli::colorize green)%s$(Cli::colorize white)\n" "$key"
                printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Description:" 
                printf "        %s\n" "${HELP_LIST[$key:'description']}"

                if ! [[ -z "${HELP_LIST[$key:'args']}" ]]; then
                    printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Arguments:" 
                    printf "        %s\n" "${HELP_LIST[$key:'args']}"
                fi

                if ! [[ -z "${HELP_LIST[$key:'output']}" ]]; then
                    printf "    $(Cli::colorize green)%s$(Cli::colorize white)\n" "Output:" 
                    printf "        %s\n" "${HELP_LIST[$key:'output']}"
                fi
            fi
        done
    fi
}

CLI['help-func':'args']="Help::list::args"
CLI['help-func':'main']="Help::list::function"
