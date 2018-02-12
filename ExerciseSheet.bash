function __static__DetermineSheetNumber(){
    local lastSheetNumber;
    lastSheetNumber=$(ls "${EXHND_finalExerciseSheetFolder}" | tail -n1 | grep -o "[0-9]\+" | sed 's/^0*//')
    if [[ $lastSheetNumber =~ ^[0-9]*$ ]]; then
        echo $((lastSheetNumber+1))
    else
        echo '1'
    fi
}

function SetExerciseSheetNumber(){
    if [ "$EXHND_exerciseSheetNumber" = '' ]; then
        EXHND_exerciseSheetNumber=$(__static__DetermineSheetNumber)
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

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
        for folder in $(GetFinalExerciseSheetFolderName)*/; do
            if [ ! -f ${folder}${EXHND_exercisesLogFilename} ]; then
                PrintWarning "Exercise log file not found in \"${folder}\" folder, not able to exclude from list some used exercises!"
                continue
            fi
            usedExercises+=( $(awk '{print $2}' ${folder}${EXHND_exercisesLogFilename}) )
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

function PickUpExercisesFromListAccordingToUserChoiceAndCheckThem(){
    __static__LookForExercisesAndMakeList
    if [ ${EXHND_fixFinal} = 'TRUE' ]; then
        local finalFolder
        finalFolder=$(GetFinalExerciseSheetFolderName ${EXHND_exerciseSheetNumber})
        if [ ! -d  ${finalFolder} ]; then
            PrintError "Folder \"$(basename ${finalFolder})\" not found in \"${EXHND_finalExerciseSheetFolder}\". Unable to fix final sheet! Aborting..."
            exit -1
        else
            if [ ! -f ${finalFolder}/${EXHND_exercisesLogFilename} ]; then
                PrintError "Exercise log file not found in \"${finalFolder}\" folder. Unable to fix final sheet! Aborting..."
                exit -1
            else
                EXHND_choosenExercises=( $(awk '{print $2}' ${finalFolder}/${EXHND_exercisesLogFilename}) )
            fi
        fi
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
    __static__CheckChoosenExercises
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function __static__CheckBlocksInFile(){
    local filename blocksName block
    filename="$1"; shift
    blocksName=( $@ )
    for block in "${blocksName[@]}"; do
        if [ $(grep -c "^[[:blank:]]*%__BEGIN_${block}__%[[:blank:]]*$" ${filename}) -ne 1 ] || [ $(grep -c "^[[:blank:]]*%__END_${block}__%[[:blank:]]*$" ${filename}) -ne 1 ]; then
            PrintError "Block %__BEGIN_${block}__%  ->  %__END_${block}__% not correctly found in \"${filename}\" file! Aborting..."; exit -2
        fi
    done
}

function __static__CheckChoosenExercises(){
    local exercise
    for exercise in ${EXHND_choosenExercises[@]}; do
        __static__CheckBlocksInFile ${EXHND_exercisePoolFolder}/${exercise}  "PACKAGES" "DEFINITIONS" "BODY"
    done
}

function CheckTexLocaldefsTemplate(){
    local line brackets oldIFS
    #Parse file line by line
    while read -r line || [[ -n "${line}" ]]; do # [[ -n "${line}" ]] is to read also last line if it does not end with \n
        if [[ $line =~ ^[[:space:]]*% ]]; then
            continue
        fi
        if [[ $line =~ \\def\\exerciseSheetSubtitlePrefix\{\} ]]; then # to skip optional fields in the check
            continue
        fi
        oldIFS=${IFS}
        IFS=$'\n'
        for brackets in $(grep -o "{[^{}]*}" <<< "${line}"); do
            if [ "$brackets" = '{}' ]; then
                PrintWarning "Found empty field(s) in \"${EXHND_texLocaldefsFilename}\"! Final result could be affected!"
                break 2
            fi
        done
        IFS=${oldIFS}
    done < "${EXHND_texLocaldefsFilename}"
    #General checks on blocks
    __static__CheckBlocksInFile "${EXHND_texLocaldefsFilename}" "PACKAGES" "DEFINITIONS" "BODY"
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function CreateTemporaryCompilationFolder(){
    [ -d "${EXHND_compilationFolder}" ] && mv "${EXHND_compilationFolder}" "${EXHND_compilationFolder}_$(date +%d.%m.%Y_%H%M%S)"
    mkdir "${EXHND_compilationFolder}" 2>/dev/null || { PrintError "Cannot create \"${EXHND_compilationFolder}\"! Aborting..." && exit -2; }
}

function ExtractBlockFromFileAndAppendToAnotherFile(){
    local inputFilename outputFilename partOfDocument
    inputFilename="$1"
    outputFilename="$2"
    partOfDocument="$3"
    awk '/%__BEGIN_'${partOfDocument}'__%/,/%__END_'${partOfDocument}'__%/' ${inputFilename} | head -n -1 | tail -n +2 >> ${outputFilename}
}

function ProduceTexAuxiliaryFile(){
    local outputFilename partOfDocument exercise
    outputFilename="$1"
    partOfDocument="$2"
    if [ ${partOfDocument} = 'PACKAGES' ]; then
        ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_themeFilename}  ${outputFilename}  ${partOfDocument}
    fi
    ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_texLocaldefsFilename}  ${outputFilename}  ${partOfDocument}
    for exercise in ${EXHND_choosenExercises[@]}; do
        ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_exercisePoolFolder}/${exercise}  ${outputFilename}  ${partOfDocument}
    done
    #NOTE: We decided to use guards to divide the parts of the exercises file, because the parsing is then easier.
    #      For example, to extract packages one could do something like,
    #         awk '{split($0, res, "%"); if(res[1] !~ /^[ ]*$/){print res[1]}}' file.tex | sed 's/^[[:blank:]]*//g' | tr '\n' ' ' | grep -Eo '\\usepackage(\[[^]]*\])?{[^}]+}'
    #      but there are many cases that could break this down.
}

function ProduceTexAuxiliaryFiles(){
    ProduceTexAuxiliaryFile ${EXHND_packagesFilename}    "PACKAGES"
    ProduceTexAuxiliaryFile ${EXHND_definitionsFilename} "DEFINITIONS"
    ProduceTexAuxiliaryFile ${EXHND_bodyFilename}        "BODY"
}

function CheckTexPackagesFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}

function CheckTexDefinitionsFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}


function ProduceTexMainFile(){
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo "\input{${EXHND_themeFilename%.tex}}"
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet[${EXHND_exerciseSheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

function MakeCompilationInTemporaryFolder(){
    local index
    cd ${EXHND_compilationFolder}
    for index in {1..2}; do
        pdflatex -interaction=batchmode ${EXHND_mainFilename} >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            PrintError "Error occurred in pdflatex compilation!! Files can be found in \"${EXHND_compilationFolder}\" directory to investigate!"
            exit 0
        fi
    done
}

function MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder(){
    local newPdfFilename
    newPdfFilename="${EXHND_temporaryFolder}/$(basename ${EXHND_mainFilename%.tex})_$(date +%d.%m.%Y_%H%M%S).pdf"
    cp "${EXHND_mainFilename/.tex/.pdf}" "${newPdfFilename}" || exit -2
    xdg-open "${newPdfFilename}" >/dev/null 2>&1 &
    rm -r "${EXHND_compilationFolder}"
}


function CreateExerciseLogfile(){
    local fileGlobalpath exercise
    fileGlobalpath=$1
    touch ${fileGlobalpath}
    for exercise in ${EXHND_choosenExercises[@]}; do
        printf "%2d    %s\n" ${EXHND_exerciseSheetNumber} ${exercise} >> ${fileGlobalpath}
    done
}

function MoveExerciseSheetFilesToFinalFolderOpenItCreateLogfileAndRemoveCompilationFolder(){
    local newExerciseFilenameWithoutExtension destinationFolder texFile
    destinationFolder=$(GetFinalExerciseSheetFolderName ${EXHND_exerciseSheetNumber})
    newExerciseFilenameWithoutExtension=$(basename ${destinationFolder})
    if [ -d "${destinationFolder}" ]; then
        if [ ${EXHND_fixFinal} = 'FALSE' ]; then
            PrintError "Folder \"$(basename ${destinationFolder})\" for final sheet is already existing! Aborting..."; exit -2
        else
            rm -r "${destinationFolder}" || exit -2
            mkdir "${destinationFolder}" || exit -2
        fi
    else
        mkdir "${destinationFolder}" || exit -2
    fi
    CreateExerciseLogfile ${destinationFolder}/${EXHND_exercisesLogFilename}
    #Rename .tex file so that then I can move to final folder all .tex files from compilation folder
    mv "${EXHND_mainFilename}"  "${EXHND_mainFilename%/*}/${newExerciseFilenameWithoutExtension}.tex" || exit -2
    for texFile in ${EXHND_compilationFolder}/*.tex; do
        mv "${texFile}" "${destinationFolder}"
    done
    cp "${EXHND_mainFilename/.tex/.pdf}" "${destinationFolder}/${newExerciseFilenameWithoutExtension}.pdf" || exit -2
    xdg-open "${destinationFolder}/${newExerciseFilenameWithoutExtension}.pdf" >/dev/null 2>&1 &
    rm -r "${EXHND_compilationFolder}"
}
