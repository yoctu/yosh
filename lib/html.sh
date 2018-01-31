#!/bin/bash

function html::print::header ()
{
    html_header_file="${html_header_file:-${html_dir}/header.html}"

    cat $html_header_file
}

function html::print::footer ()
{
    html_footer_file="${html_footer_file:-${html_dir}/footer.html}"

    cat $html_footer_file
}

function html::print::out ()
{
    local body_file="$1"

    [[ -z "$body_file" ]] && return
    
    # Set content-type
    http::send::content-type text/html

    # Print header
    html::print::header
   
    # Print body
    cat $body_file

    # Print footer
    html::print::footer
}
