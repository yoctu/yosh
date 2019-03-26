# Eval == evil
# So this should be used instead of eval

Eval(){
    [private] cmd="$*"
    [private] tmpCmdFile="$(Mktemp::create)"

    printf '%s' "$cmd" > $tmpCmdFile

    bash $tmpCmdFile
}

alias eval='Eval'
