#!/bin/bash

# convert array to json
# keep old method... this is depcretated
alias json-to-array='Json::to::array'
alias array-to-json='array::to::json'

# trim a variable
trim(){
    local variable="$1" new_variable

    [[ -z "$variable" ]] && return
    
    typeset -n new_variable="$variable"
    new_variable="${new_variable% }"
    new_variable="${new_variable# }"

    declare -g ${variable}="$new_variable"
}


# XXX: use gridsite-clients instead
# decode url
#function url_decode ()
#{
#    local value="$1"
#    value="${value//+/ }"
#    value="${value//%/\\x}"
#    
#    echo -e "$value"
#}
#
#function url_encode() 
#{
#    local _length="${#1}"
#
#    for (( _offset = 0 ; _offset < _length ; _offset++ ))
#    do
#        _print_offset="${1:_offset:1}"
#
#        case "${_print_offset}" in
#            [a-zA-Z0-9.~_-]) printf "${_print_offset}" ;;
#            ' ') printf + ;;
#            *) printf '%%%X' "'${_print_offset}" ;;
#        esac
#
#    done
#}

