App::find(){
    if [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}" ]]; then
        printf '%s' "${DOCUMENT_ROOT%/}/../app/${uri}"
    elif [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}.sh" ]]; then
        printf '%s' "${DOCUMENT_ROOT%/}/../app/${uri}.sh"
    elif [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}.bash" ]]; then
        printf '%s' "${DOCUMENT_ROOT%/}/../app/${uri}.bash"
    else
        return 1
    fi
}

App::search(){
    if [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}" ]]; then
        router_run="App::source"
    elif [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}.sh" ]]; then
        router_run="App::source"
    elif [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}.bash" ]]; then
        router_run="App::source"
    else
        return 1
    fi
}

App::source(){
    [private] file

    file="$(App::find)"

    [[ -z "$file" ]] && return 1

    source $file
}

# create alias to lower case
alias app::find='App::find'
alias app::source='App::source'

ROUTERS+=( "App::search" )
