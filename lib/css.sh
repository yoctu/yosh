

Css::router::check(){
    [private] css_file="${1#css/}" uri="$1"

    [[ "$uri" =~ ^css.* ]] || return

    [[ -z "$css_file" ]] && return 1
    [[ -f "${css_dir}/$css_file" ]] || return 1

    router_run="Css::print::out"
}

Css::print::out(){
    [private] css_file="${1#css/}" uri="$1"

    # Set content-type
    Http::send::content-type text/css
    Http::send::header Cache-Control "max-age=3600, public"
   
    # Print css file
    cat ${css_dir}/$css_file

}

alias css::print::out='Css::print::out'

ROUTERS+=("Css::router::check")
