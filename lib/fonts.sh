

Fonts::print::out(){
    [private] fonts_file="${1#fonts/}" 
    [private] extension="${1##*.}"
    
    [[ -z "$fonts_file" ]] && return 1
    [[ -f "${fonts_dir}/$fonts_file" ]] || return 1

    # Set content-type
    Http::send::content-type image/$extension
    Http::send::header Cache-Control "max-age=3600, public"

    [[ "$extension" == "svg" ]] && Http::send::content-type image/$extension+xml
   
    # Print fonts file
    cat ${fonts_dir}/$fonts_file

}

alias fonts::print::out='Fonts::print::out'
ROUTERS+=("Fonts::print::out")
