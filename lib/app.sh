function app::find ()
{
    if [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}" ]]
    then
        echo "${DOCUMENT_ROOT%/}/../app/${uri}"
    elif [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}.sh" ]]
    then
        echo "${DOCUMENT_ROOT%/}/../app/${uri}.sh"
    elif [[ -f "${DOCUMENT_ROOT%/}/../app/${uri}.bash" ]]
    then
        echo "${DOCUMENT_ROOT%/}/../app/${uri}.bash"
    else
        return 1
    fi
}

function app::source ()
{
    local file

    file="$(app::find)"

    [[ -z "$file" ]] && return 1

    source $file
}

