

Img::print::out(){
    [private] img_file="${1#img/}"
    
    [[ -z "$img_file" ]] && return 1
    [[ -f "${img_dir}/$img_file" ]] || return 1

    # Set content-type
    Http::send::content-type "$(file -b --mime-type $img_dir/$img_file)"
    Http::send::header Cache-Control "max-age=3600, public"
   
    # Print img file
    cat ${img_dir}/$img_file

}

ROUTERS+=( "Img::print::out" )

alias img::print::out='Img::print::out'
