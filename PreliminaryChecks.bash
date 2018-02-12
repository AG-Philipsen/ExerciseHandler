function __static__IsInvokingPositionWrong(){
    local listOfFiles listOfFolders filename foldername
    listOfFiles=( ${EXHND_texLocaldefsFilename} )
    listOfFolders=( ${EXHND_exercisePoolFolder}
                    ${EXHND_solutionPoolFolder}
                    ${EXHND_finalExerciseSheetFolder}
                    ${EXHND_finalSolutionSheetFolder}
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

function CheckInvokingPosition(){
    if __static__IsInvokingPositionWrong; then
        PrintError "Invoking position of the Exercise Handler seems to be wrong! Run the setup to create missing files/folders! Aborting..."; exit -1
    fi
}
