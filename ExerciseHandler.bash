#!/bin/bash

#-------------------------------------------------------------------------------------------------#
#      ____ _  __ ____ ___   _____ ____ ____ ____      __ __ ___    _  __ ___   __    ____ ___    #
#     / __/| |/_// __// _ \ / ___//  _// __// __/     / // // _ |  / |/ // _ \ / /   / __// _ \   #
#    / _/ _>  < / _/ / , _// /__ _/ / _\ \ / _/      / _  // __ | /    // // // /__ / _/ / , _/   #
#   /___//_/|_|/___//_/|_| \___//___//___//___/     /_//_//_/ |_|/_/|_//____//____//___//_/|_|    #
#                                                                                                 #
#-------------------------------------------------------------------------------------------------#
#                                                                                                 #
#         Copyright (c) 2016-2018 Alessandro Sciarra: sciarra@th.physik.uni-frankfurt.de          #
#         Copyright (c) 2016        Francesca Cuteri:  cuteri@th.physik.uni-frankfurt.de          #
#                                                                                                 #
#-------------------------------------------------------------------------------------------------#

readonly EXHND_repositoryDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Sourcing auxiliary file(s)
source ${EXHND_repositoryDirectory}/GlobalVariables.bash         || exit -2
source ${EXHND_repositoryDirectory}/OutputFunctionality.bash     || exit -2
source ${EXHND_repositoryDirectory}/PreliminaryChecks.bash       || exit -2
source ${EXHND_repositoryDirectory}/CommandLineParser.bash       || exit -2
source ${EXHND_repositoryDirectory}/Setup.bash                   || exit -2
source ${EXHND_repositoryDirectory}/NewExercise.bash             || exit -2
source ${EXHND_repositoryDirectory}/AuxiliaryFunctions.bash      || exit -2
source ${EXHND_repositoryDirectory}/ListUsedExercises.bash       || exit -2
source ${EXHND_repositoryDirectory}/ExerciseSheet.bash           || exit -2
source ${EXHND_repositoryDirectory}/SolutionSheet.bash           || exit -2

#Warning that the script is in developement phase!
PrintWarning -n "Script under developement and in a beta phase!" "Not everything is guaranteed to work!!"

#------------------------------------------------------------------------------------------------------------------#

DefineGlobalVariables
CheckInvokingPosition
ParseCommandLineParameters "$@"

if [ ${EXHND_doSetup} = 'TRUE' ]; then
    MakeSetup
elif [ ${EXHND_produceNewExercise} = 'TRUE' ]; then
    ProduceNewEmptyExercise
elif [ ${EXHND_listUsedExercises} = 'TRUE' ]; then
    DisplayExerciseLogfile
elif [ ${EXHND_makeExerciseSheet} = 'TRUE' ]; then
    SetSheetNumber
    CheckTexLocaldefsTemplate
    PickUpExercisesFromListAccordingToUserChoice
    CheckChoosenExercises
    #TeX part: set up main and sub-files before compilation
    CreateTemporaryCompilationFolder
    ProduceTexAuxiliaryFiles 'EXERCISE'
    CheckTexPackagesFile
    CheckTexDefinitionsFile
    ProduceExerciseTexMainFile
    MakeCompilationInTemporaryFolder
    if [ $EXHND_isFinal = 'FALSE' ]; then
        MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder 'EXERCISE'
    else
        MoveSheetFilesToFinalFolderOpenItCompilationFolder 'EXERCISE'
    fi
elif [ ${EXHND_makeSolutionSheet} = 'TRUE' ]; then
    #PrintError "\"-S\" option not implemented yet!"; exit -1
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

elif [ ${EXHND_makeExam} = 'TRUE' ]; then
    PrintError "\"-X\" option not implemented yet!"; exit -1
else
    PrintWarning "No mutually exclusive option was specified!" "Use the \"--help\" option to get more information!"
fi

exit 0
