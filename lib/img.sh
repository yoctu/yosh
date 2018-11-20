

Img::print::out(){
    local img_file="$1"
    
    [[ -z "$img_file" ]] && return 1
    [[ -f "${img_dir}/$img_file" ]] || return 1

    # Set content-type
    http::send::content-type "$(file -b --mime-type $img_dir/$img_file)"
    http::send::header Cache-Control "max-age=3600, public"
   
    # Print img file
    cat ${img_dir}/$img_file

}

alias img::print::out='Img::print::out'
