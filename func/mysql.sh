# Mysql connector

function mysql-escape ()
{
    local string="$@"

    string="${string%%;*}"

    printf "%q" "$string"
}

function mysql-connector ()
{
    mysql -h ${mysql_host} -P ${mysql_port} -u ${mysql_user} --database=${mysql_dbname} -p${mysql_password} -e "$@" 2>/dev/null
    echo END
}

function mysql-to-json ()
{
    typeset -A arr
    while read line
    do
        if [[ "${line}" =~ .*row.* || "$line" == "END" ]]
        then
            continue
        elif [[ "${line}" =~ key.* ]]
        then
            key="${line#*: }"
        elif ! [[ "${line}" =~ .*row.* || "$line" == "END" ]]
        then
            arr[${key}]="${line#*: }"
            unset key
        fi

    done < <(mysql-connector "$@\\G")

    [[ ! -z "${arr[@]}" ]] && results+="$(array-to-json arr),"

    echo "{ \"$service\": ${results%,} }"
}

