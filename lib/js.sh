
Js::router::check(){
    [private] js_file="${1#js/}"

    [[ -z "$js_file" ]] && return
    [[ -f "${js_dir}/$js_file" ]] || return 1

    router_run="Js::print::out"
}

Js::print::out(){
    [private] js_file="${1#js/}"

    [[ -z "$js_file" ]] && return
    [[ -f "${js_dir}/$js_file" ]] || return 1

    # Set content-type
    Http::send::content-type application/javascript
    Http::send::header Cache-Control "max-age=3600, public"   

    # Print javascript file
    cat ${js_dir}/$js_file

}

ROUTERS+=("Js::router::check")

alias js::print::out='Js::print::out'
