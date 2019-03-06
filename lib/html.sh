

Html::print::header(){
    html_header_file="${html_header_file:-${html_dir}/header.html}"

    cat $html_header_file
}

Html::print::footer(){
    html_footer_file="${html_footer_file:-${html_dir}/footer.html}"

    cat $html_footer_file
}

Html::router::check(){
    [private] body_file="${html_dir%/}/${1%.html}.html"

    [[ ! -f "$body_file" ]] && return 1
    
    router_run="Html::print::out"
}

Html::print::out(){
    [private] body_file="${html_dir%/}/${1%.html}.html"

    [[ ! -f "$body_file" ]] && return 1
    # Set content-type
    Http::send::content-type text/html

    # Print header
    Html::print::header
   
    # Print body
    cat $body_file

    # Print footer
    Html::print::footer
}

ROUTERS+=("Html::router::check")

alias html::print::header='Html::print::header'
alias html::print::footer='Html::print::footer'
alias html::print::out='Html::print::out'

