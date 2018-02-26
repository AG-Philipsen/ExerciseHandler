function ProduceExerciseSheet(){
    SetSheetNumber
    CheckTexLocaldefsAndLatexTheme
    PickUpExercisesFromListAccordingToUserChoice
    SetListOfFilesToBeUsedAndCheckThem
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProduceExerciseTexMainFile
    MakeCompilationInTemporaryFolder
    if [ $EXHND_isFinal = 'FALSE' ]; then
        MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder
    else
        MoveSheetFilesToFinalFolderOpenPdfAndRemoveCompilationFolder
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceSolutionSheet(){
    SetSheetNumber
    CheckTexLocaldefsAndLatexTheme
    ReadOutExercisesFromFinalExerciseSheetLogFile
    SetListOfFilesToBeUsedAndCheckThem
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProduceSolutionTexMainFile
    MakeCompilationInTemporaryFolder
    if [ $EXHND_isFinal = 'FALSE' ]; then
        MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder
    else
        MoveSheetFilesToFinalFolderOpenPdfAndRemoveCompilationFolder
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceExamSheet(){
    SetSheetNumber #Needed if final
    CheckTexLocaldefsAndLatexTheme
    PickUpExercisesFromListAccordingToUserChoice
    SetListOfFilesToBeUsedAndCheckThem
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProduceExamTexMainFile
    MakeCompilationInTemporaryFolder
    if [ $EXHND_isFinal = 'FALSE' ]; then
        MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder
    else
        MoveSheetFilesToFinalFolderOpenPdfAndRemoveCompilationFolder
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProducePresenceSheet(){
    SetSheetNumber
    CheckTexLocaldefsAndLatexTheme
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProducePresenceSheetTexMainFile
    MakeCompilationInTemporaryFolder
    MoveSheetFilesToFinalFolderOpenPdfAndRemoveCompilationFolder
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
