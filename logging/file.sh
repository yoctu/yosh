# Custom file logging

# We ue now logger
#logDir="${logDir:-/var/log/$application_name}"
#
#[[ -d "$logDir" ]] || { sudo mkdir $logDir; sudo chown -R $USER $logDir; }

function file::write ()
{

    #echo "$@" | sudo tee -a $file_to_write &>/dev/null
    logger -t esm "$*"

}

function file::log ()
{
    case "$_level" in
        crit|error)     file_to_write="$logDir/$application_name-error.log"             ;;
        *)              file_to_write="$logDir/$application_name-access.log"            ;;    
    esac

    
    file::write "$(date "+%d-%m-%Y %H:%M") :: $_tag :: $_message"
}
