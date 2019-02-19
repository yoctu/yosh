[public:assoc] LOG

# Config should be like this
# LOG['@log']="FUNCNAME"
# LOG['@deprecated']="FUNCNAME"
# LOG['@error']="FUNCNAME"
# LOG['@audit']="FUNCNAME"
#
# The function's should be in the func dir
# 
# Default Logging
LOG['@log']="rsyslog::log"
LOG['@deprecated']="rsyslog::deprecated"
LOG['@error']="rsyslog::error"
LOG['@audit']="rsyslog::audit"

Log::print(){
    # This function can be overwritten or create just an alias @log
    [private] _msg="$*"

    ${LOG['@log']} "${application_name^^} Log: $_msg"
}

Log::print::deprecated(){
    [private] _name="$*"
    
    ${LOG['@deprecated']} "${application_name^^} Depcrecated: $_name will no longer be available in the next Release!"
}

Log::print::error(){
    [private] _msg="$*"
    
    ${LOG['@error']} "${application_name^^} Error: $_msg"
}

Log::print::audit(){
    [private] _msg="$*"

    ${LOG['@audit']} "${application_name^^} Audit: $_msg"
}

Log::stack::trace(){
    [private:int] err=$?

    set +o xtrace

    [private] code="${1:-1}"

    Log::print::error "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}. '${BASH_COMMAND}' exited with status $err"
    # Print out the stack trace described by $function_stack  

    if (( ${#FUNCNAME[@]} >> 2 )); then
        Log::print::error "Call tree:"
        for ((i=1;i<${#FUNCNAME[@]}-1;i++)); do
            Log::print::error " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
        done
    fi

    Log::print::error "Exiting with status ${code}"
    exit $err
}


alias log::print='Log::print'
alias log::print::deprecated='Log::print::deprecated'
alias log::print::error='Log::print::error'
alias log::print::audit='Log::print::audit'

alias @log='Log::print'
alias @deprecated='Log::print::deprecated'
alias @error='Log::print::error'
alias @audit='Log::print::audit'

