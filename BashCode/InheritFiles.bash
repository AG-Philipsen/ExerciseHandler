function __static__PrepareTemporaryFolderForTarball() {
    local folder
    folder="$1"
    if [ -d "${folder}" ]; then
        mv "${folder}" "${folder}_$(date +%d.%m.%Y_%H%M%S)" | exit -2
    fi
    mkdir "${folder}" | exit -2
}  

function __static__CreateTarballFromFolderContent() {
    local folder tarballName
    folder="$1"
    tarballName="$2"
    # https://stackoverflow.com/a/39530409
    find "${folder}" -printf "%P\n" | tar -cf "${tarballName}" --no-recursion -C "${folder}" -T -
    if [ $? -ne 0 ]; then
        PrintError "Error occurred creating the \"${tarballName}\" tarball!"; exit -1
    else
        PrintInfo "Tarball \"${tarballName}\" successfully created!"
    fi
}

function __static__CollectPdfFilesCopyingToTemporaryFolder() {
    local tmpFolder listOfPdfFilesForTarball folder file
    tmpFolder="$1"
    for folder in "${EXHND_finalExerciseSheetFolder}" "${EXHND_finalSolutionSheetFolder}" "${EXHND_finalExamSheetFolder}"; do
        listOfPdfFilesForTarball+=( $(find $(pwd -P) -path "${folder}/*.pdf") )
    done
    for file in  "${listOfPdfFilesForTarball[@]}"; do
        if [ -f "${tmpFolder}/$(basename "${file}")" ]; then
            PrintInternal "Pdf with the same name but in different location were collected and this should not happen!"; exit -1
        fi
        cp "${file}" "${tmpFolder}/$(basename "${file}")"
    done
}

function __static__CollectMaterialToBeInheritedCopyingToTemporaryFolder() {
    local tmpFolder folder listOfPastExersisesFilename
    tmpFolder="$1"
    for folder in "${EXHND_exercisePoolFolder}" "${EXHND_solutionPoolFolder}" "${EXHND_figuresFolder}"; do
        cp -r "${folder}" "${tmpFolder}" | exit -2
    done
    cp "${EXHND_themeFilename}" "${tmpFolder}" | exit -2
    cp "${EXHND_texLocaldefsFilename}" "${tmpFolder}" | exit -2
    listOfPastExersisesFilename="PastSheetsStructure_${EXHND_tarballPrefix}.txt"
    echo '' > "${tmpFolder}/${listOfPastExersisesFilename}" | exit -2
    DisplayExerciseLogfile >> "${tmpFolder}/${listOfPastExersisesFilename}" | exit -2
    #Redirect standard output to file
    exec 3>&1 1>"${tmpFolder}/README"
    echo ''
    echo "This tarball was produced with the version \"$(git -C "${EXHND_repositoryDirectory}" describe --long --abbrev=40 --tags)\""
    echo 'where this string, RIGHT to LEFT, contains (using \"-\" as field separator):'
    echo '  1) The SHA-1 of the commit at which the tarball was created'
    echo '  2) The number of commits ahead from the previous tag'
    echo '  3) The name of the last tag.'
    echo ''
    echo ''
    echo 'The files and directories contained in this folder are ready to be used by the Exercise Handler'
    echo 'and they should be used in this way. Create an empty folder where you wish to work, move to it'
    echo 'and give'
    echo ''
    echo '                      ExerciseHandler -I <path_to_the_tarball>'
    echo ''
    echo 'where ExerciseHandler is the main bash script and the tarball is the one whose name should finish'
    echo "with \"${EXHND_tarballExerciseHandlerPostfix}\". In this way the setup with some extraction from the tarball will"
    echo 'take place and you will be ready to use the Exercise Handler.'
    echo ''
    echo "The only file which is kind of extra, but that could be useful for you is \"${listOfPastExersisesFilename}\""
    echo 'which contains a list of how the material was organised in the past lecture. Use the command'
    echo ''
    echo "                         cat ${listOfPastExersisesFilename}"
    echo ''
    echo 'to visualise it in a colourful format.'
    #Restore standard output
    exec 1>&3
}

function __static__CreateTarball() {
    local tarballName whichTar tmpFolder
    tarballName="$1"
    whichTar="$2"
    tmpFolder="${EXHND_temporaryFolder}/CollectionOfFilesForTarball"
    __static__PrepareTemporaryFolderForTarball "${tmpFolder}"
    if [ ${whichTar} = 'PDF' ]; then
        __static__CollectPdfFilesCopyingToTemporaryFolder "${tmpFolder}"
    elif [ ${whichTar} = 'ALL' ]; then
        __static__CollectMaterialToBeInheritedCopyingToTemporaryFolder "${tmpFolder}"
    else
        PrintInternal "Variable \"whichTar\" set to unknown value!"; exit -1
    fi
    __static__CreateTarballFromFolderContent "${tmpFolder}" "${tarballName}"
}

function CreateTarballsToLetWorkBeInherited() {
    local pdfTarball exerciseHandlerTarball
    pdfTarball="${EXHND_tarballPrefix}${EXHND_tarballPdfPostfix}"
    if [ -f "${pdfTarball}" ]; then
        PrintWarning "Tarball \"${pdfTarball}\" already existing! Not creating it!"
    else
    __static__CreateTarball  "${pdfTarball}"              'PDF'
    fi
    exerciseHandlerTarball="${EXHND_tarballPrefix}${EXHND_tarballExerciseHandlerPostfix}"
    if [ -f "${exerciseHandlerTarball}" ]; then
        PrintWarning "Tarball \"${exerciseHandlerTarball}\" already existing! Not creating it!"
    else
        __static__CreateTarball  "${exerciseHandlerTarball}"  'ALL'
    fi
}
