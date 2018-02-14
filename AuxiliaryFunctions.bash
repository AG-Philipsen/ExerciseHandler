function GetFinalSheetFolderName(){
    local typeOfSheet number string
    typeOfSheet="$1"; number="$2"
    if [ "${typeOfSheet}" = 'EXERCISE' ]; then
        string="${EXHND_finalExerciseSheetFolder}/${EXHND_finalExerciseSheetPrefix}"
    elif [ "${typeOfSheet}" = 'SOLUTION' ]; then
        string="${EXHND_finalSolutionSheetFolder}/${EXHND_finalSolutionSheetPrefix}"
    else
        PrintInternal "Error in \"${FUNCNAME[0]}\" function, wrong typeOfSheet passed! (typeOfSheet=\"${typeOfSheet}\")"; exit -1
    fi
    if [ "${number}" = '' ]; then
        echo ${string}
    else
        echo ${string}$(printf "%02d" ${number})
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function __static__DetermineSheetNumber(){
    local typeOfSheet lastSheetNumber;
    typeOfSheet="$1"
    if [[ ! ${typeOfSheet} =~ ^(EXERCISE|SOLUTION)$ ]]; then
        PrintInternal "Error in \"${FUNCNAME[0]}\" function, wrong typeOfSheet passed! (typeOfSheet=\"${typeOfSheet}\")"; exit -1
    fi
    lastSheetNumber=$(ls "${EXHND_finalExerciseSheetFolder}" | tail -n1 | grep -o "[0-9]\+" | sed 's/^0*//')
    if [[ $lastSheetNumber =~ ^[0-9]*$ ]]; then
        if [ "${typeOfSheet}" = 'EXERCISE' ]; then
            echo $((lastSheetNumber+1))
        elif [ "${typeOfSheet}" = 'SOLUTION' ]; then
            echo ${lastSheetNumber}
        fi
    else
        echo '1'
    fi
}

function SetSheetNumber(){
    if [ "${EXHND_sheetNumber}" = '' ]; then
        if [ ${EXHND_makeExerciseSheet} = 'TRUE' ]; then
            EXHND_sheetNumber=$(__static__DetermineSheetNumber 'EXERCISE')
        elif [ ${EXHND_makeSolutionSheet} = 'TRUE' ]; then
            EXHND_sheetNumber=$(__static__DetermineSheetNumber 'SOLUTION')
        else
            PrintInternal "Error in ${FUNCNAME[0]}, entered unexpected branch!"; exit -1
        fi
        if [[ ! $EXHND_sheetNumber =~ ^[1-9][0-9]*$ ]]; then
            PrintError "Unable to determine sheet number!"; exit -1
        fi
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ReadOutExercisesFromFinalExerciseSheetLogFile(){
    local finalFolder
    finalFolder="$(GetFinalSheetFolderName 'EXERCISE' ${EXHND_sheetNumber})"
    if [ ! -d  "${finalFolder}" ]; then
        PrintError "Folder \"$(basename ${finalFolder})\" not found in \"${EXHND_finalExerciseSheetFolder}\"! Aborting..."
        exit -1
    else
        if [ ! -f "${finalFolder}/${EXHND_exercisesLogFilename}" ]; then
            PrintError "Exercise log file not found in \"${finalFolder}\" folder! Aborting..."
            exit -1
        else
            EXHND_choosenExercises=( $(awk '{print $2}' "${finalFolder}/${EXHND_exercisesLogFilename}") )
        fi
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function CheckBlocksInFile(){
    local filename blocksName block
    filename="$1"; shift
    blocksName=( $@ )
    for block in "${blocksName[@]}"; do
        if [ $(grep -c "^[[:blank:]]*%__BEGIN_${block}__%[[:blank:]]*$" ${filename}) -ne 1 ] || [ $(grep -c "^[[:blank:]]*%__END_${block}__%[[:blank:]]*$" ${filename}) -ne 1 ]; then
            PrintError "Block %__BEGIN_${block}__%  ->  %__END_${block}__% not correctly found in \"${filename}\" file! Aborting..."; exit -2
        fi
    done
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

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
    CheckBlocksInFile "${EXHND_texLocaldefsFilename}" "PACKAGES" "DEFINITIONS" "BODY"
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function CreateTemporaryCompilationFolder(){
    [ -d "${EXHND_compilationFolder}" ] && mv "${EXHND_compilationFolder}" "${EXHND_compilationFolder}_$(date +%d.%m.%Y_%H%M%S)"
    mkdir "${EXHND_compilationFolder}" 2>/dev/null || { PrintError "Cannot create \"${EXHND_compilationFolder}\"! Aborting..." && exit -2; }
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function __static__ExtractBlockFromFileAndAppendToAnotherFile(){
    local inputFilename outputFilename partOfDocument
    inputFilename="$1"
    outputFilename="$2"
    partOfDocument="$3"
    awk '/%__BEGIN_'${partOfDocument}'__%/,/%__END_'${partOfDocument}'__%/' ${inputFilename} | head -n -1 | tail -n +2 >> ${outputFilename}
}

function __static__ProduceTexAuxiliaryFile(){
    local outputFilename partOfDocument listOfFiles file
    outputFilename="$1"; partOfDocument="$2"; shift 2
    listOfFiles=( "$@" )
    if [[ ! ${partOfDocument} =~ ^(PACKAGES|DEFINITIONS|BODY)$  ]]; then
        PrintInternal "Error in \"${FUNCNAME[0]}\" function, wrong partOfDocument passed! (partOfDocument=\"${partOfDocument}\")"; exit -1
    else
        if [ ${partOfDocument} = 'PACKAGES' ] || [ ${partOfDocument} = 'DEFINITIONS' ]; then
            __static__ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_themeFilename}  ${outputFilename}  ${partOfDocument}
        fi
        __static__ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_texLocaldefsFilename}  ${outputFilename}  ${partOfDocument}
        for file in "${listOfFiles[@]}"; do
            __static__ExtractBlockFromFileAndAppendToAnotherFile  ${file}  ${outputFilename}  ${partOfDocument}
        done
        #NOTE: We decided to use guards to divide the parts of the exercises file, because the parsing is then easier.
        #      For example, to extract packages one could do something like,
        #         awk '{split($0, res, "%"); if(res[1] !~ /^[ ]*$/){print res[1]}}' file.tex | sed 's/^[[:blank:]]*//g' | tr '\n' ' ' | grep -Eo '\\usepackage(\[[^]]*\])?{[^}]+}'
        #      but there are many cases that could break this down.
    fi
}

function ProduceTexAuxiliaryFiles(){
    local listOfFiles typeOfSheet; typeOfSheet="$1"
    if [ "${typeOfSheet}" = 'EXERCISE' ]; then
        listOfFiles=( "${EXHND_choosenExercises[@]/#/${EXHND_exercisePoolFolder}/}" ) #Prepend to each array element (last / is a real / in path)
    elif [ "${typeOfSheet}" = 'SOLUTION' ]; then
        listOfFiles=( "${EXHND_choosenExercises[@]/#/${EXHND_solutionPoolFolder}/}" ) #Prepend to each array element (last / is a real / in path)
    else
        PrintInternal "Error in \"${FUNCNAME[0]}\" function, wrong typeOfSheet passed! (typeOfSheet=\"${typeOfSheet}\")"; exit -1
    fi
    __static__ProduceTexAuxiliaryFile ${EXHND_packagesFilename}    "PACKAGES"    "${listOfFiles[@]}"
    __static__ProduceTexAuxiliaryFile ${EXHND_definitionsFilename} "DEFINITIONS" "${listOfFiles[@]}"
    __static__ProduceTexAuxiliaryFile ${EXHND_bodyFilename}        "BODY"        "${listOfFiles[@]}"
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function CheckTexPackagesFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}

function CheckTexDefinitionsFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

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

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder(){
    local newPdfFilename suffix
    prefix="$1"
    newPdfFilename="${EXHND_temporaryFolder}/${prefix}_$(basename ${EXHND_mainFilename%.tex})_$(date +%d.%m.%Y_%H%M%S).pdf"
    cp "${EXHND_mainFilename/.tex/.pdf}" "${newPdfFilename}" || exit -2
    xdg-open "${newPdfFilename}" >/dev/null 2>&1 &
    rm -r "${EXHND_compilationFolder}"
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function __static__CreateExerciseLogfile(){
    local fileGlobalpath exercise
    fileGlobalpath=$1
    touch ${fileGlobalpath}
    for exercise in ${EXHND_choosenExercises[@]}; do
        printf "%2d    %s\n" ${EXHND_sheetNumber} ${exercise} >> ${fileGlobalpath}
    done
}

function MoveSheetFilesToFinalFolderOpenItCompilationFolder(){
    local typeOfSheet destinationFolder newFilenameWithoutExtension texFile
    typeOfSheet="$1"
    destinationFolder=$(GetFinalSheetFolderName ${typeOfSheet} ${EXHND_sheetNumber})
    newFilenameWithoutExtension=$(basename ${destinationFolder})
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
    if [ ${typeOfSheet} = 'EXERCISE' ]; then
        __static__CreateExerciseLogfile ${destinationFolder}/${EXHND_exercisesLogFilename}
    fi
    #Rename .tex main file so that then I can move to final folder all .tex files from compilation folder
    #(moving before and renaming after is possible but require some more work)
    mv "${EXHND_mainFilename}"  "${EXHND_mainFilename%/*}/${newFilenameWithoutExtension}.tex" || exit -2
    for texFile in ${EXHND_compilationFolder}/*.tex; do
        mv "${texFile}" "${destinationFolder}"
    done
    cp "${EXHND_mainFilename/.tex/.pdf}" "${destinationFolder}/${newFilenameWithoutExtension}.pdf" || exit -2
    xdg-open "${destinationFolder}/${newFilenameWithoutExtension}.pdf" >/dev/null 2>&1 &
    rm -r "${EXHND_compilationFolder}"
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
