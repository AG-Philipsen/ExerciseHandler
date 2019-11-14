function __static__PrintMessageToScreen()
{
    local initialEndline continuation typeOfMessage messageColor fullMessage
    initialEndline=""; continuation='FALSE'
    [ "$1" = '-n' ] && initialEndline='\n' && shift
    [ "$1" = '-c' ] && initialEndline='\e[1A' && continuation='TRUE' && shift
    typeOfMessage="$1"; shift
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
    [ $continuation = 'TRUE' ] && typeOfMessage=${typeOfMessage//?/ }
    #Prepare full message on several lines leaving the exact amount of space at the beginning of
    #each line except the first one (i.e. as many spaces as the chars in typeOfMessage).
    fullMessage="$(printf "$messageColor%s\n   ${typeOfMessage//?/ }" "$@")"
    if [ $continuation = 'FALSE' ]; then
        printf "$initialEndline \e[1m\e[4m${messageColor}${typeOfMessage}\033[24m:\033[22m ${fullMessage//%/%%}\n\033[0m"
    else
        printf "$initialEndline ${messageColor}${typeOfMessage}  ${fullMessage//%/%%}\n\033[0m"
    fi
}

function PrintInfo(){
    __static__PrintMessageToScreen "INFO" "$@"
}

function PrintWarning(){
    __static__PrintMessageToScreen "WARNING" "$@"
}

function PrintError(){
    if [ "$1" = '-c' ]; then
        shift; __static__PrintMessageToScreen -c "ERROR" "$@"  >&2
    else
        __static__PrintMessageToScreen "ERROR" "$@"  >&2
    fi
}

function PrintInternal(){
    __static__PrintMessageToScreen "INTERNAL" "$@" "Please contact the developers reporting this message and how you run the script."  >&2
}
