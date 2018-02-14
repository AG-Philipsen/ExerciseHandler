function ProduceExerciseSheet(){
    SetSheetNumber
    CheckTexLocaldefsTemplate
    PickUpExercisesFromListAccordingToUserChoice
    SetListOfFilesToBeUsedAndCheckThem 'EXERCISE'
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProduceExerciseTexMainFile
    MakeCompilationInTemporaryFolder
    if [ $EXHND_isFinal = 'FALSE' ]; then
        MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder 'EXERCISE'
    else
        MoveSheetFilesToFinalFolderOpenItCompilationFolder 'EXERCISE'
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceSolutionSheet(){
    SetSheetNumber
    CheckTexLocaldefsTemplate
    ReadOutExercisesFromFinalExerciseSheetLogFile
    SetListOfFilesToBeUsedAndCheckThem 'SOLUTION'
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles
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

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
