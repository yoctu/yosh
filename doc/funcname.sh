Doc::func::create::args 'Type::function::exist' 'function names'
Doc::func::create::description 'Type::function::exist' "Check if function exist and if command is a function or not"
Doc::func::create::output 'Type::function::exist' "Return code: 0 == ok, 1 == nok"
Doc::func::create::example 'Type::function::exist' "Type::function::exist func1 func2 func3"

Doc::func::create::args 'Type::command::exist' 'command names'
Doc::func::create::description 'Type::command::exist' 'Check if a command exist'
Doc::func::create::output 'Type::command::exist' 'Return code: 0 == ok, 1 == nok'
Doc::func::create::example 'Type::command::exist' 'Type::command::exist command1 command2 command3'

Doc::func::create::args 'Type::array::contains' 'key' 'arrayname'
Doc::func::create::description 'Type::array::contains' 'Check if an array contains the given value'
Doc::func::create::output 'Type::array::contains' 'Return code: 0 == ok, 1 == nok'
Doc::func::create::example 'Type::array::contains' 'Type::array::contains "key" "arrayname"'

Doc::func::create::args 'Type::array::is::assoc' 'arrayname'
Doc::func::create::description 'Type::array::is::assoc' 'Check if an array is a associative array'
Doc::func::create::output 'Type::array::is::assoc' 'Return code: 0 == ok, 1 == nok'
Doc::func::create::example 'Type::array::is::assoc' 'Type::array::is::assoc "arrayname"'

Doc::func::create::args 'Type::variable::set' 'variable names'
Doc::func::create::description 'Type::variable::set' 'Check if a variable is set'
Doc::func::create::output 'Type::variable::set' 'Return code: 0 == ok, 1 == nok'
Doc::func::create::example 'Type::variable::set' 'Type::variable::set variablename1 variablename2 variablename3'

Doc::func::create::args 'Type::array::get::key' 'level' 'arrayname'
Doc::func::create::description 'Type::array::get::key' 'Get the given level of an array
        The level should be a key, seperated by :'
Doc::func::create::output 'Type::array::get::key' 'Return all the key given by the level'
Doc::func::create::example 'Type::array::get::key' 'Type::array::get::key "level1" "arrayname"'

Doc::func::create::args 'Type::fusion::array::in::assoc' 'array' 'assoc' 'string to be inserted before the array'
Doc::func::create::description 'Type::fusion::array::in::assoc' 'Fussion an array in assoc
        The format will bey assoc["givenString":0]=value'
Doc::func::create::output 'Type::fusion::array::in::assoc' "Return 0"
Doc::func::create::example 'Type::fusion::array::in::assoc' 'Type::fusion::array::in::assoc array assoc string'

Doc::func::create::args 'Type::array::fusion' 'srcArray' 'dstArray' 'regex'
Doc::func::create::description 'Type::array::fusion' 'Fusion two array associatiove based on a regex to fusion
        The regex should be a matched key level of the srcArray what you want to fusion'
Doc::func::create::output 'Type::array::fusion' 'return 0'
Doc::func::create::example 'Type::array::fusion' 'Type::array::fusion srcArray dstArray regex'

Doc::func::create::args 'Type::variable::int' 'variablename'
Doc::func::create::description 'Type::variable::int' 'Check if variable is int'
Doc::func::create::output 'Type::variable::int' 'Return code: 0 == ok, 1 == nok'
Doc::func::create::example 'Type::variable::int' 'Type::variable::int variablename'

Doc::func::create::description '[]' '[int]                   alias to local -i 
        [public:int]            alias to declare -gi
        [private:int]           alias to local -i
        [private]               alias to local
        [public]                alias to declare -g
        [string]                alias to declare
        [private:string]        alias to local
        [public:string]         alias to declare -g
        [map]                   alias to local -n
        [public:map]            alias to declare -gn
        [private:map]           alias to local -n
        [array]                 alias to declare -a
        [private:array]         alias to local -a
        [public:array]          alias to declare -ga
        [assoc]                 alias to declare -A
        [private:assoc]         alias to local -A
        [public:assoc]          alias to declare -gA
        [const]                 alias to declare -r'


