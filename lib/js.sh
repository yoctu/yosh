#!/bin/bash

function js::print::out ()
{
    local js_file="$1"

    [[ -z "$js_file" ]] && return
    [[ -f "${js_dir}/$js_file" ]] || return 1

    # Set content-type
    http::send::content-type application/javascript
   
    # Print javascript file
    cat ${js_dir}/$js_file

}
