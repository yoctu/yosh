

Js::print::out(){
    local js_file="$1"

    [[ -z "$js_file" ]] && return
    [[ -f "${js_dir}/$js_file" ]] || return 1

    # Set content-type
    http::send::content-type application/javascript
    http::send::header Cache-Control "max-age=3600, public"   

    # Print javascript file
    cat ${js_dir}/$js_file

}

alias js::print::out='Js::print::out'
