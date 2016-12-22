function PrintWarning(){
    printf "\n\e[38;5;11m \e[1m\e[4mWARNING\e[24m:\e[21m %s\e[0m\n\n" "$1"
}

function PrintError(){
    printf "\n\e[38;5;9m \e[1m\e[4mERROR\e[24m:\e[21m %s\e[0m\n\n" "$1"
}

function ParseCommandLineParameters(){
    while [ "$1" != '' ]; do
        case $1 in
            -h | --help )
                printf "\e[38;5;2m\n"
                printf "Helper to be written!"
                printf "\e[0m\n\n"
                exit 0
                shift ;;
            -n | --newExercise )
                PRODUCE_NEW_EXERCISE='TRUE'
                shift ;;
            -f | --final )
                printf "\e[38;5;9m\n Option \e[1m$1\e[21m! still to be implemented! Aborting...\n\n\e[0m"; exit -1; shift ;;
            *)
                printf "\e[38;5;9m\n Unrecognized option \e[1m$1\e[21m! Aborting...\n\n\e[0m"; exit -1; shift ;;
        esac
    done
}

function ProduceNewEmptyExercise(){
    printf "\e[38;5;207m\n Please, insert the exercise filename: \e[0m\e[s"
    local NEW_EXERCISE_FILENAME
    while read NEW_EXERCISE_FILENAME; do
        [ "$NEW_EXERCISE_FILENAME" = '' ] && printf "\e[u\e[1A" && continue
        if [ -f $EXERCISE_POOL_FOLDER/$NEW_EXERCISE_FILENAME ]; then
            printf "\n\e[1;38;5;202m File \"$NEW_EXERCISE_FILENAME\" already existing!\e[21m\e[38;5;11m Please, provide a different name: \e[0m\e[s"
            continue
        else
            break
        fi
    done
    #Redirect standard output to file
    exec 3>&1 1>$EXERCISE_POOL_FOLDER/$NEW_EXERCISE_FILENAME
    echo -e '%__BEGIN_PACKAGES__%\n\n%__END_PACKAGES__%\n\n\n'
    echo -e '%__BEGIN_DEFINITIONS__%\n\n%__END_DEFINITIONS__%\n\n\n'
    echo -e '%__BEGIN_BODY__%\n\n%__END_BODY__%\n\n\n'
    #Restore standard output
    exec 1>&3    
}

function CreateTexLocaldefsTemplate(){
    #Template production, overwriting the file
    rm -f $TEX_LOCALDEFS_FILENAME
    #Redirect standard output to file
    exec 3>&1 1>$TEX_LOCALDEFS_FILENAME
    echo -e '%__BEGIN_PACKAGES__%\n\n%__END_PACKAGES__%\n\n\n'
    echo '%__BEGIN_DEFINITIONS__%'
    echo '\def\lecture{}   % '
    echo '\def\professor{} % '
    echo '\def\tutor{}     % '
    echo '\def\tutorMail{} % '
    echo '\def\semester{}  % '
    echo -e '%__END_DEFINITIONS__%\n\n\n'
    #Restore standard output
    exec 1>&3
}

function CheckBlocksInFile(){
    local FILENAME="$1"; shift
    local BLOCKS_NAME=( $@ )
    for BLOCK in "${BLOCKS_NAME[@]}"; do
        if [ $(grep -c "^[[:blank:]]*%__BEGIN_${BLOCK}__%[[:blank:]]*$" $FILENAME) -ne 1 ] || [ $(grep -c "^[[:blank:]]*%__END_${BLOCK}__%[[:blank:]]*$" $FILENAME) -ne 1 ]; then
            PrintError "Block %__BEGIN_${BLOCK}__%  ->  %__END_${BLOCK}__% not correctly found in \"$FILENAME\" file! Aborting..."; exit -2
        fi
    done
}

function CheckTexLocaldefsTemplate(){
    local LINE BLOCK
    #Parse file line by line
    while read -r LINE || [[ -n "$LINE" ]]; do # [[ -n "$LINE" ]] is to read also last line if it does not end with \n
        if [ "$(grep -o "{.*}" <<< "$LINE")" = '{}' ]; then
            PrintWarning "Found empty fields in \"$TEMPLATE_FILENAME\"! Final result could be affected!\e[0m\n\n"
            return
        fi
    done < "$TEX_LOCALDEFS_FILENAME"
    #General checks on blocks
    CheckBlocksInFile "$TEX_LOCALDEFS_FILENAME" "PACKAGES" "DEFINITIONS" "BODY"
} 

function LookForExercisesAndMakeList(){
    if [ ! -d $EXERCISE_POOL_FOLDER ]; then
        PrintError "No exercise pool folder \"$EXERCISE_POOL_FOLDER\" has been found! Aborting..."; exit -2
    fi
    EXERCISE_LIST=( $(ls $EXERCISE_POOL_FOLDER/*.tex 2> /dev/null | xargs -d '\n' -n 1 basename) )
    if [ ${#EXERCISE_LIST[@]} -eq 0 ]; then
        PrintError "No exercise .tex file has been found in pool folder \"$EXERCISE_POOL_FOLDER\"! Aborting..."; exit -2
    fi
}

function PrintListOfExercises(){
    printf "\e[1;38;5;207m\n List of exercises found in the pool\e[21m:\n\n\e[0m"
    local GIVEN_LIST=( $@ )
    local INDEX=0
    for INDEX in "${!GIVEN_LIST[@]}" ; do  GIVEN_LIST[$INDEX]="$(printf "%3d" $((INDEX+1)))) ${GIVEN_LIST[$INDEX]}"; done
    local COLUMNS_TERMINAL=$(tput cols)
    local LONGEST_FILENAME_LENGTH=$(printf "%s\n" "${GIVEN_LIST[@]}" | awk '{print length}' | sort -n | tail -n1)
    local COLUMNS_WIDTH=$((LONGEST_FILENAME_LENGTH+10))
    local MAX_NUMBER_OF_COLUMNS=$((COLUMNS_TERMINAL/COLUMNS_WIDTH))
    local FORMAT_STRING=""; for((INDEX=0; INDEX<MAX_NUMBER_OF_COLUMNS; INDEX++)); do FORMAT_STRING+="%-${COLUMNS_WIDTH}s"; done
    printf "$FORMAT_STRING\n" "${GIVEN_LIST[@]}"

    #TODO: Print list going vertically and not horizontally!
}

function PickupExercises(){
    printf "\e[38;5;207m\n Please, insert the exercise numbers that you wish to include in the exercise sheet (sperated by space): \e[0m\e[s"
    local SELECTED_EXERCISES INDEX
    local GIVEN_LIST=( $@ )
    while read -a SELECTED_EXERCISES; do
        [ ${#SELECTED_EXERCISES[@]} -eq 0 ] && printf "\e[u\e[1A" && continue
        for INDEX in ${SELECTED_EXERCISES[@]}; do
            if [[ $INDEX =~ ^[1-9][0-9]*$ ]] && [ $INDEX -le ${#GIVEN_LIST[@]} ]; then
                continue
            else
                printf "\n\e[1;38;5;208m Invalid input!\e[21m\e[38;5;207m Please, insert the \e[1mexercise numbers sperated by space\e[21m: \e[0m\e[s"
                continue 2
            fi
        done
        break
    done
    for INDEX in ${SELECTED_EXERCISES[@]}; do
        CHOOSEN_EXERCISES+=( ${GIVEN_LIST[$((INDEX-1))]} )
    done
}

function CheckChoosenExercises(){
    for EXERCISE in ${CHOOSEN_EXERCISES[@]}; do
        CheckBlocksInFile $EXERCISE_POOL_FOLDER/$EXERCISE  "PACKAGES" "DEFINITIONS" "BODY"
    done    
}


#=========================================================================================================================================================#

function ExtractBlockFromFileAndAppendToAnotherFile(){
    local INPUT_FILE="$1"
    local OUTPUT_FILE="$2"
    local PART_OF_DOCUMENT="$3"
    awk '/%__BEGIN_'$PART_OF_DOCUMENT'__%/,/%__END_'$PART_OF_DOCUMENT'__%/' $INPUT_FILE | head -n -1 | tail -n +2 >> $OUTPUT_FILE
}

function ProduceTexAuxiliaryFile(){
    local OUTPUT_FILE="$1"
    local PART_OF_DOCUMENT="$2"
    local EXERCISE
    ExtractBlockFromFileAndAppendToAnotherFile  $TEX_LOCALDEFS_FILENAME  $OUTPUT_FILE  $PART_OF_DOCUMENT
    for EXERCISE in ${CHOOSEN_EXERCISES[@]}; do
        ExtractBlockFromFileAndAppendToAnotherFile  $EXERCISE_POOL_FOLDER/$EXERCISE  $OUTPUT_FILE  $PART_OF_DOCUMENT
    done
    #NOTE: We decided to use guards to divide the parts of the exercises file, because the parsing is then easier.
    #      For example, to extract packages one could do something like,
    #         awk '{split($0, res, "%"); if(res[1] !~ /^[ ]*$/){print res[1]}}' file.tex | sed 's/^[[:blank:]]*//g' | tr '\n' ' ' | grep -Eo '\\usepackage(\[[^]]*\])?{[^}]+}'
    #      but there are many cases that could break this down.
}

function CheckTexPackagesFile(){
    PrintWarning "Function \"$FUNCNAME\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}

function CheckTexDefinitionsFile(){
    PrintWarning "Function \"$FUNCNAME\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}


function ProduceTexMainFile(){
    local TEX_MAIN_FILENAME="$1"
    rm -f $TEX_MAIN_FILENAME
    #Redirect standard output to file
    exec 3>&1 1>$TEX_MAIN_FILENAME
    #Template production, overwriting the file
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo ''
    echo "\input{$REPOSITORY_DIRECTORY/ClassicTheme}"
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo '  \Sheet[1]'
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}
