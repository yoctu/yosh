

Player::print::out(){
    [private] player_file="$1"
    
    [[ -z "$player_file" ]] && return 1
    [[ -f "${player_dir}/$player_file" ]] || return 1

    # Set content-type
    Http::send::content-type "$(file -b --mime-type $player_dir/$player_file)"
    Http::send::header Cache-Control "max-age=3600, public"
   
    # Print player file
    cat ${player_dir}/$player_file

}

ROUTERS+=( "Player::print::out" )

alias player::print::out='Player::print::out'
