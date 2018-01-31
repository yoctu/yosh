#!/bin/bash

# NOTE:
#       password, user, host and database should be save in configfile in config/
#
# Config:
#       db_user=
#       db_password=
#       db_host=
#       db_name=
#       db_port=

# convert array to json
# only to use on single result
function mysql-to-json ()
{
    local arrayname="$1" query="${@:2}"

    [[ -z "$db_user" || -z "$db_password" || -z "$db_host" || -z "$db_name" || -z "$db_port" ]] && return

    while read line
    do
        declare -gA ${arrayname}[${line%%:*}]="${line#*:}"
    done < <(mysql -u $db_user -p$db_password -h $db_host -P $db_port $db_name -e "${query%;}\G;" 2>/dev/null | grep -Ev "^$")
}

# generate sql requeste and save it in the database
# only generates insert
function json-to-mysql ()
{
    local table="$1" json="${@:2}" column query

    [[ -z "$db_user" || -z "$db_password" || -z "$db_host" || -z "$db_name" || -z "$db_port" ]] && return

    json-to-array array "$json"

    for key in "${!array[@]}"
    do
        column+="${key},"
        value+="'${array[$key]}',"
    done

    query="INSERT INTO $table (${column%,}) VALUES (${value%,})"

    mysql -u $db_user -p$db_password -H $db_host -P $db_port $db_name -e "$query" || return

    unset array

    return 1
}

