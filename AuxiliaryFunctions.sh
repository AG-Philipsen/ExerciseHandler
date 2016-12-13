function ParseCommandLineParameters(){
    while [ "$1" != '' ]; do
        case $1 in
            -h | --help )
                printf "\e[38;5;2m\n"
                printf "Helper to be written!"
                printf "\e[0m\n\n"
                exit 0
                shift ;;
            *)
                printf "\e[38;5;9m\n Unrecognized option \e[1m$1\e[21m! Aborting...\n\n\e[0m"; exit -1; shift ;;
        esac
    done
}

function CreateTexLocaldefsTemplate(){
    local OUTPUT_FILENAME="$1"
    #Redirect standard output to file
    exec 3>&1 1>$OUTPUT_FILENAME
    #Template production, overwriting the file
    rm -f $OUTPUT_FILENAME
    echo '\def\lecture{}   % '
    echo '\def\professor{} % '
    echo '\def\tutor{}     % '
    echo '\def\tutorMail{} % '
    echo '\def\semester{}  % '
    #Restore standard output
    exec 1>&3
}

function CheckTexLocaldefsTemplate(){
    local TEMPLATE_FILENAME="$1"
    #Parse file line by line
    while read -r LINE || [[ -n "$LINE" ]]; do # [[ -n "$LINE" ]] is to read also last line if it does not end with \n
        echo
        #Add parsing
    done < "$TEMPLATE_FILENAME"  && unset -v 'LINE'

}

function ProduceTexMainFile(){
    local TEX_MAIN_FILENAME="$1"
    #Redirect standard output to file
    exec 3>&1 1>$TEX_MAIN_FILENAME
    #Template production, overwriting the file
    rm -f $TEX_MAIN_FILENAME
    echo '\documentclass[a4paper]{article}'
    echo '\input{Packages}'
    echo '\input{Preamble}'
    echo '\input{Localdefs}'
    echo '\input{Document}'
    #Restore standard output
    exec 1>&3
}
