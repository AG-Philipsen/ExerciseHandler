function __static__LookForExercisesAndMakeList(){
    if [ ! -d ${EXHND_exercisePoolFolder} ]; then
        PrintError "No exercise pool folder \"${EXHND_exercisePoolFolder}\" has been found! Aborting..."; exit -2
    fi
    EXHND_exerciseList=( $(ls ${EXHND_exercisePoolFolder}/*.tex 2> /dev/null | xargs -d '\n' -n 1 basename) )
    if [ ${#EXHND_exerciseList[@]} -eq 0 ]; then
        PrintError "No exercise .tex file has been found in pool folder \"${EXHND_exercisePoolFolder}\"! Aborting..."; exit -2
    fi
    if [ ${EXHND_displayAlreadyUsedExercises} = 'FALSE' ]; then
        local folder usedExercises exerciseOfList index
        usedExercises=()
        for folder in $(GetFinalSheetFolderGlobalPathWithoutNumber 'EXERCISE')*/; do
            if [ ! -f ${folder}${EXHND_exercisesLogFilename} ]; then
                PrintWarning "Exercise log file not found in \"${folder}\" folder, not able to exclude from list some used exercises!"
                continue
            fi
            usedExercises+=( $(awk '{print $2}' ${folder}${EXHND_exercisesLogFilename}) )
        done
        for folder in $(GetFinalSheetFolderGlobalPathWithoutNumber 'EXAM')*/; do
            if [ ! -f ${folder}${EXHND_examLogFilename} ]; then
                PrintWarning "Exercise log file not found in \"${folder}\" folder, not able to exclude from list some used exercises!"
                continue
            fi
            usedExercises+=( $(awk '{print $2}' ${folder}${EXHND_examLogFilename}) )
        done
        for exerciseOfUsed in ${usedExercises[@]}; do
            for index in ${!EXHND_exerciseList[@]}; do
                if [ ${EXHND_exerciseList[$index]} = ${exerciseOfUsed} ]; then
                    unset -v 'EXHND_exerciseList[$index]'
                    continue 2
                fi
            done
        done
    fi
}

function __static__PrintListOfExercises(){
    local givenList index numberOfTerminalColumns longestFilenameLength\
          tableColumnsWidth maxNumberOfColumnsInTable stringFormat
    printf "\e[1;38;5;207m\n List of exercises found in the pool\e[21m:\n\n\e[0m"
    givenList=( $@ )
    index=0
    for index in "${!givenList[@]}" ; do
        givenList[${index}]="$(printf "%3d" $((index+1)))) ${givenList[${index}]}"
    done
    numberOfTerminalColumns=$(tput cols)
    longestFilenameLength=$(printf "%s\n" "${givenList[@]}" | awk '{print length}' | sort -n | tail -n1)
    tableColumnsWidth=$((longestFilenameLength+10))
    maxNumberOfColumnsInTable=$((numberOfTerminalColumns/tableColumnsWidth))
    stringFormat=""; for((index=0; index<maxNumberOfColumnsInTable; index++)); do stringFormat+="%-${tableColumnsWidth}s"; done
    printf "${stringFormat}\n" "${givenList[@]}"

    #TODO: Print list going vertically and not horizontally!
}

function __static__GetArrayFromCommaSeparatedListOfIntegersAcceptingRanges(){
    local string
    string="$1"
    awk 'BEGIN{RS=","}/\-/{split($0, res, "-"); if(res[1]<=res[2]){for(i=res[1]; i<=res[2]; i++){printf "%d\n", i}}else{for(i=res[1]; i>=res[2]; i--){printf "%d\n", i}}; next}{printf "%d\n", $0}' <<< "${string}"
}

function __static__FillChoosenExercisesArray(){
    local index pool numbersOfChosenExercises
    numbersOfChosenExercises=( $1 )
    pool=( $2 )
    for index in ${numbersOfChosenExercises[@]}; do
        EXHND_choosenExercises+=( ${pool[$((index-1))]} )
    done
}

function __static__IsAnyExerciseNotExisting(){
    local index maximum numbersOfChosenExercises
    maximum=$1; shift; numbersOfChosenExercises=( $@ )
    for index in ${numbersOfChosenExercises[@]}; do
        if [ ${index} -gt ${maximum} ]; then
            return 0
        fi
    done
    return 1
}

function __static__PickupExercises(){
    printf "\e[38;5;14m\n Please, insert the exercise numbers that you wish to include in the exercise sheet.\n"
    printf " Use a comma separated list WITHOUT SPACES; ranges X-Y are allowed (boundaries included)\n"
    printf " and order is respected, e.g. \"7,3-1,9\" is expanded to [7 3 2 1 9]: \e[0m\e[s"
    local selectedExercises index givenList oldIFS
    givenList=( $@ )
    while read selectedExercises; do #Here selectedExercises is a variable
        [ "${selectedExercises}" = '' ] && printf "\e[u\e[1A" && continue
        if [[ ! ${selectedExercises} =~ ^[1-9][0-9]*([,\-][1-9][0-9]*)*$ ]]; then
            printf "\n\e[1;38;5;208m Invalid input!\e[21m\e[38;5;14m Please, insert the exercise numbers: \e[0m\e[s"; continue
        fi
        selectedExercises=( $(__static__GetArrayFromCommaSeparatedListOfIntegersAcceptingRanges ${selectedExercises}) ) #Here selectedExercises becomes an array!
        if __static__IsAnyExerciseNotExisting ${#givenList[@]} ${selectedExercises[@]}; then
            printf "\n\e[1;38;5;208m Not existent exercise inserted!\e[21m\e[38;5;14m Please, insert the exercise numbers: \e[0m\e[s"; continue 2
        fi
        break
    done
    __static__FillChoosenExercisesArray "${selectedExercises[*]}" "${givenList[*]}" #https://stackoverflow.com/a/16628100
    echo
}

function PickUpExercisesFromListAccordingToUserChoice(){
    __static__LookForExercisesAndMakeList
    if [ ${EXHND_fixFinal} = 'TRUE' ]; then
        ReadOutExercisesFromFinalSheetLogFile
    else
        if [ "$EXHND_exercisesFromPoolAsNumbers" = '' ]; then
            __static__PrintListOfExercises ${EXHND_exerciseList[@]}
            __static__PickupExercises ${EXHND_exerciseList[@]}
        else
            EXHND_exercisesFromPoolAsNumbers=( $(__static__GetArrayFromCommaSeparatedListOfIntegersAcceptingRanges ${EXHND_exercisesFromPoolAsNumbers}) )
            if __static__IsAnyExerciseNotExisting ${#EXHND_exerciseList[@]} ${EXHND_exercisesFromPoolAsNumbers[@]}; then
                PrintError "Some of the chosen exercises are not existing! Aborting..."; exit 0
            else
                __static__FillChoosenExercisesArray "${EXHND_exercisesFromPoolAsNumbers[*]}" "${EXHND_exerciseList[*]}" #https://stackoverflow.com/a/16628100
            fi
        fi
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ReadOutExercisesFromFinalSheetLogFile(){
    local finalFolder logFile
    if [ ${EXHND_makeExam} = 'TRUE' ] || [ ${EXHND_solutionOfExam} = 'TRUE' ]; then
        finalFolder=$(GetFinalSheetFolderGlobalPathWithoutNumber 'EXAM') || exit -1
        logFile=${EXHND_examLogFilename}
    else
        finalFolder=$(GetFinalSheetFolderGlobalPathWithoutNumber 'EXERCISE') || exit -1
        logFile=${EXHND_exercisesLogFilename}
    fi
    finalFolder+=$(printf "%02d" ${EXHND_sheetNumber})
    if [ ! -d  "${finalFolder}" ]; then
        PrintError "Folder \"$(basename ${finalFolder})\" not found in \"${EXHND_finalExerciseSheetFolder}\"! Aborting..."
        exit -1
    else
        if [ ! -f "${finalFolder}/${logFile}" ]; then
            PrintError "Log file not found in \"${finalFolder}\" folder! Aborting..."
            exit -1
        else
            EXHND_choosenExercises=( $(awk '{print $2}' "${finalFolder}/${logFile}") )
        fi
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
