# set default services

sessionPath="${sessionPath:-tmp}"
login_method="${login_method:-auth::request}"
login_unauthorized="${login_unauthorized:-auth::unauthorized}"
auth_encode="${auth_encode:-base64encode}"
auth_decode="${auth_decode:-base64decode}"

base64encode(){
    printf '%s' "$*" | base64
}

base64decode(){
    printf '%s' "$*" | base64 -d
}
