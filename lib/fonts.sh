#!/bin/bash

Fonts::print::out(){
    local fonts_file="$1" extension="${1##*.}"
    
    [[ -z "$fonts_file" ]] && return 1
    [[ -f "${fonts_dir}/$fonts_file" ]] || return 1

    # Set content-type
    http::send::content-type image/$extension
    http::send::header Cache-Control "max-age=3600, public"

    [[ "$extension" == "svg" ]] && http::send::content-type image/$extension+xml
   
    # Print fonts file
    cat ${fonts_dir}/$fonts_file

}

alias fonts::print::out='Fonts::print::out'
