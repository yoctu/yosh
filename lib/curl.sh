# Lib Curl
[public:assoc] CURL

Yosh::lib::helper curl url
Yosh::lib::helper curl opt:auth:basic:user
Yosh::lib::helper curl opt:auth:basic:password
Yosh::lib::helper curl opt:method
Yosh::lib::helper curl opt:header:content-type
Yosh::lib::helper curl opt:header:authorization

Curl::set::opt::header(){
    [private] key="$1"
    [private] value="$2"

    Type::variable::set key value || return 1

    CURL['opt':'header':$key]="$value"
}

Curl::set::get::param(){
    [private] key="$1"
    [private] value="$2"

    Type::variable::set key value || return 1

    CURL['get':'param':$key]="$value"
}

Curl::run(){
    [private] location="$1"
    [private] headerFile="$(Mktemp::create)"
    [private] netrcFile="$(Mktemp::create)"
    [private] getParam
    [private] requestMethod="${CURL['opt':'method']:-GET}"

    Curl::get::url &>/dev/null || return 1

    if Curl::get::opt::auth::basic::user &>/dev/null && Curl::get::opt::auth::basic::password &>/dev/null; then
        curlAuth="-u $(Curl::get::opt::auth::basic::user):$(Curl::get::opt::auth::basic::password)"
    fi

    while read header; do
        printf '%s: %s\n' "$header" "${CURL['opt':'header':"$header"]}" >> $headerFile
    done < <(Type::array::get::key opt:header CURL)
    
    while read get; do
        getParam+="$(printf '%s' "$get" | urlencode.pl)=$(printf '%s' "${CURL['get':'param':"$get"]}" | urlencode.pl)&"
    done < <(Type::array::get::key get:param CURL)

    getParam="?${getParam%&}"

    curl $curlAuth -X "${requestMethod^^}" -H @$headerFile "${CURL['url']%/}/${location#/}$getParam"
}
