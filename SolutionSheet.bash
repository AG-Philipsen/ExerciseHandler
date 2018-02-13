function ProduceSolutionSheet(){
    SetSheetNumber
    CheckTexLocaldefsTemplate
    ReadOutExercisesFromFinalExerciseSheetLogFile
    CheckSolutionsFiles
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles 'SOLUTION'
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProduceSolutionTexMainFile
    MakeCompilationInTemporaryFolder
    if [ $EXHND_isFinal = 'FALSE' ]; then
        MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder 'SOLUTION'
    else
        MoveSheetFilesToFinalFolderOpenItCompilationFolder 'SOLUTION'
    fi
}

#=============================================================================================================================================================#

function CheckSolutionsFiles(){
    local index exercise string
    for index in ${!EXHND_choosenExercises[@]}; do
        exercise=${EXHND_choosenExercises[$index]}
        if [ ! -f ${EXHND_solutionPoolFolder}/${exercise} ]; then
            string="Solution \"${exercise}\" not found in \"${EXHND_solutionPoolFolder}\" folder."
            if [ ${EXHND_skipMissingSolutions} = 'TRUE' ]; then
                PrintWarning "${string}"
                unset -v 'EXHND_choosenExercises[$index]'
            else
                PrintError "${string}"
                exit -1
            fi
        else
            CheckBlocksInFile ${EXHND_solutionPoolFolder}/${exercise}  "PACKAGES" "DEFINITIONS" "BODY"
        fi
    done
    EXHND_choosenExercises=( "${EXHND_choosenExercises[@]}" ) #Make potentially sparsa array not sparse
    if [ ${#EXHND_choosenExercises[@]} -eq 0 ]; then
        PrintError "List of solution files empty! No file was found, aborting..."; exit -1
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceSolutionTexMainFile(){
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
    echo "  \Sheet[Solution of exercise][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]" #subtitle passed to give freedom in customized theme!
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
