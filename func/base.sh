#!/bin/bash

# convert array to json
# keep old method... this is depcretated
alias json-to-array='Json::to::array'
alias array-to-json='Json::create::simple'

# trim a variable
trim(){
    local variable="$1" new_variable

    [[ -z "$variable" ]] && return
    
    typeset -n new_variable="$variable"
    new_variable="$(printf '%s' "$new_variable" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' )"

}


