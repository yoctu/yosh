#!/bin/bash

function fonts::print::out ()
{
    local fonts_file="$1" extension="${1##*.}"
    
    [[ -z "$fonts_file" ]] && return 1
    [[ -f "${fonts_dir}/$fonts_file" ]] || return 1

    # Set content-type
    http::send::content-type image/$extension
   
    # Print fonts file
    cat ${fonts_dir}/$fonts_file

}
