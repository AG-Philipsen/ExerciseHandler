function __static__PrintMessageToScreen()
{
    local initialEndline typeOfMessage messageColor fullMessage
    typeOfMessage="$1"; shift
    initialEndline=""
    [ "$1" = '-n' ] && initialEndline='\n' && shift
    case "$typeOfMessage" in
        INFO )
            messageColor='\033[92m' ;;
        WARNING )
            messageColor='\033[93m' ;;
        ERROR )
            messageColor='\033[91m' ;;
        * )
            messageColor='\033[38;5;208m'
    esac
    #Prepare full message on several lines leaving the exact amount of space at the beginning of
    #each line except the first one (i.e. as many spaces as the chars in typeOfMessage).
    fullMessage="$(printf "$messageColor%s\n   ${typeOfMessage//?/ }" "$@")"
    printf "$initialEndline \e[1m\e[4m${messageColor}${typeOfMessage}\033[24m:\033[21m ${fullMessage//%/%%}\n\033[0m"
}

function PrintInfo(){
    __static__PrintMessageToScreen "INFO" "$@"
}

function PrintWarning(){
    __static__PrintMessageToScreen "WARNING" "$@"
}

function PrintError(){
    __static__PrintMessageToScreen "ERROR" "$@"  >&2
}

function PrintInternal(){
    __static__PrintMessageToScreen "INTERNAL" "$@" "Please contact the developers reporting this message and how you run the script."  >&2
}
