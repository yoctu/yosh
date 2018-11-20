#!/bin/bash

Player::print::out(){
    local player_file="$1"
    
    [[ -z "$player_file" ]] && return 1
    [[ -f "${player_dir}/$player_file" ]] || return 1

    # Set content-type
    http::send::content-type "$(file -b --mime-type $player_dir/$player_file)"
    http::send::header Cache-Control "max-age=3600, public"
   
    # Print player file
    cat ${player_dir}/$player_file

}

alias player::print::out='Player::print::out'
