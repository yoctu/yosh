

Html::print::header(){
    html_header_file="${html_header_file:-${html_dir}/header.html}"

    cat $html_header_file
}

Html::print::footer(){
    html_footer_file="${html_footer_file:-${html_dir}/footer.html}"

    cat $html_footer_file
}

Html::print::out(){
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

alias html::print::header='Html::print::header'
alias html::print::footer='Html::print::footer'
alias html::print::out='Html::print::out'
