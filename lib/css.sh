

Css::print::out(){
    local css_file="$1"

    [[ -z "$css_file" ]] && return 1
    [[ -f "${css_dir}/$css_file" ]] || return 1

    # Set content-type
    http::send::content-type text/css
    http::send::header Cache-Control "max-age=3600, public"
   
    # Print css file
    cat ${css_dir}/$css_file

}

alias css::print::out='Css::print::out'
