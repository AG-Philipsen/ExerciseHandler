function ProduceExerciseSheet(){
    SetSheetNumber
    CheckTexLocaldefsTemplate
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
    CheckTexLocaldefsTemplate
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
    CheckTexLocaldefsTemplate
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
    CheckTexLocaldefsTemplate
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProducePresenceSheetTexMainFile
    MakeCompilationInTemporaryFolder
    MoveSheetFilesToFinalFolderOpenPdfAndRemoveCompilationFolder
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
