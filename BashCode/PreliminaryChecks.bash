function __static__IsInvokingPositionWrong(){
    local listOfFiles listOfFolders filename foldername
    listOfFiles=( ${EXHND_texLocaldefsFilename}
                  ${EXHND_themeFilename} )
    listOfFolders=( ${EXHND_exercisePoolFolder}
                    ${EXHND_solutionPoolFolder}
                    ${EXHND_finalExerciseSheetFolder}
                    ${EXHND_finalSolutionSheetFolder}
                    ${EXHND_finalExamSheetFolder}
                    ${EXHND_figuresFolder}
                    ${EXHND_temporaryFolder} )
    for filename in "${listOfFiles[@]}"; do
        if [ ! -f "${filename}" ]; then
            return 0
        fi
    done
    for foldername in "${listOfFolders[@]}"; do
        if [ ! -d "${foldername}" ]; then
            return 0
        fi
    done
    return 1
}

function __static__CheckInvokingPosition(){
    if __static__IsInvokingPositionWrong; then
        PrintError "Invoking position of the Exercise Handler seems to be wrong! Run the setup to create missing files/folders! Aborting..."; exit -1
    fi
}

function __static__CheckExistenceOfAuxiliaryFiles() {
    if [ ${EXHND_makePresenceSheet} = 'TRUE' ]; then
        if [ ! -f ${EXHND_listOfStudentsFilename} ]; then
            touch ${EXHND_listOfStudentsFilename}
            PrintWarning "File \"$(basename ${EXHND_listOfStudentsFilename})\" with students list not found in folder \"$(basename ${EXHND_presenceSheetFolder})\". Created empty one!"
        fi
    fi
}

function MakePreliminaryChecks(){
    __static__CheckInvokingPosition
    __static__CheckExistenceOfAuxiliaryFiles
}
