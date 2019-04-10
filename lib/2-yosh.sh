# Yosh functions 

[public:assoc] YOSH
[public:array] YOSH_ON_EXIT
[public:array] YOSH_ON_START

Yosh::on::start::add(){
    [private] onStart="$1"

    Type::variable::set onStart || { printf "Variable not set" >&2; return 1; }

    YOSH_ON_START+=("$onStart")
}

Yosh::on::start(){
    for function in "${YOSH_ON_START[@]}"; do
        Type::function::exist "$function" || { printf "Is not a function" >&2; return 1; }
        $function
    done
}

Yosh::on::exit::add(){
    [private] onExit="$1"

    Type::variable::set onExit || { printf "Variable not set" >&2; return 1; }

    YOSH_ON_EXIT+=("$onExit")
}

Yosh::on::exit(){
    for function in "${YOSH_ON_EXIT[@]}"; do
        Type::function::exist "$function" || { printf "Is not a function" >&2; return 1; }
        $function
    done
}

Yosh::lib::helper(){
    [private] array="${1,,}"
    [private] key="$2"

    alias ${array^}::set::$key="Yosh::lib::helper::setter ${array^^} $key"
    alias ${array^}::get::$key="Yosh::lib::helper::getter ${array^^} $key"
}

Yosh::lib::helper::getter(){
    [private:map] array="$1"
    [private] key="$2"

    printf '%s' "${array[$key]}"
}

Yosh::lib::helper::setter(){
    [private:map] array="$1"
    [private] key="$2"
    [private] value="$3"

    array[$key]="$value"
}


Yosh::on::start::add Http::read::get
Yosh::on::start::add Http::read::post
Yosh::on::start::add Http::read::cookie

Yosh::on::exit::add Log::print::error::array
Yosh::on::exit::add Mktemp::remove::public::all

