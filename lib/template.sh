# Templating
# We could set a lot of template, that can be nice :p

# we should accept recursivity

# templatedir should be set in the config
# default should be DOCUMENT_ROOT/template
# should we set categories?
# For example mysql is in this dir or mysql have this file..
# XXX: Check if it is good or not

function template::copy ()
{
    [[ -z "$template_dir" ]] && return

    local _src="$1" _dest="$2" tmpFile
 
    tmpFile="$(mktemp -p)"

    cp $template_dir/$_src $tmpFile

    while read line 
    do
        parsedLine="${line%@}"
        parsedLine="${parsedLine#@}"

        sed -i "s/$line/${!parsedLine}" $tmpFile
    done < <(grep -E -o "@.*@" $tmpFile)

    # hmmm why sudo?
   sudo mv $tmpFile $_dest
}
