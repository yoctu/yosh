#!/bin/bash

function img::print::out ()
{
    local img_file="$1" extension="${1##*.}"
    
    [[ -z "$img_file" ]] && return 1
    [[ -f "${img_dir}/$img_file" ]] || return 1

    # Set content-type
    http::send::content-type image/$extension
    http::send::header Cache-Control "max-age=3600, public"

    [[ "$extension" == "svg" ]] && http::send::content-type image/$extension+xml
   
    # Print img file
    cat ${img_dir}/$img_file

}
