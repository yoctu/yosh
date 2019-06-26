[public:assoc] MKTEMP
[public:array] MKTEMP_PUBLIC
[public:array] MKTEMP_PRIVATE

MKTEMP['config':'tmpdir']="/dev/shm"

Mktemp::set::public(){
    MKTEMP_PUBLIC+=("$1")
}

Mktemp::set::private(){
    MKTEMP_PRIVATE+=("$1")
}

Mktemp::remove::public(){
    [private] filename="$1"

    for key in "${!MKTEMP_PUBLIC[@]}"; do
        if [[ "$filename" == "${MKTEMP_PUBLIC[$key]}" ]]; then
            unset MTEKMP_PUBLIC[$key]
        fi

        if [[ -f "$filename" ]]; then
            rm $filename
        fi
    done
}

Mktemp::remove::private(){
    [private] filename="$1"

    for key in "${!MKTEMP_PRIVATE[@]}"; do
        if [[ "$filename" == "${MKTEMP_PRIVATE[$key]}" ]]; then
            unset MTEKMP_PRIVATE[$key]
        fi

        if [[ -f "$filename" ]]; then
            rm $filename
        fi
    done
}

Mktemp::remove::public::all(){
    [[ -d "${MKTEMP['config':'tmpdir']%/}/$USERPID" ]] && rm -rf ${MKTEMP['config':'tmpdir']%/}/$USERPID

    unset MKTEMP_PUBLIC      
}

Mktemp::create(){
    [private] priority="${1:-public}"
    [private] tmpFile

    if [[ "$priority" == "public" ]]; then
        [[ ! -d "${MKTEMP['config':'tmpdir']%/}/$USERPID" ]] && mkdir ${MKTEMP['config':'tmpdir']%/}/$USERPID
        tmpFile="$(mktemp -p "${MKTEMP['config':'tmpdir']%/}/$USERPID")"
    else
        tmpFile="$(mktemp -p "${MKTEMP['config':'tmpdir']}")"
    fi

    Mktemp::set::$priority "$tmpFile"

    @return "$tmpFile"
}

