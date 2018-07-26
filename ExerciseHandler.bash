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
source ${EXHND_repositoryDirectory}/BashCode/GlobalVariables.bash         || exit -2
source ${EXHND_repositoryDirectory}/BashCode/OutputFunctionality.bash     || exit -2
source ${EXHND_repositoryDirectory}/BashCode/PreliminaryChecks.bash       || exit -2
source ${EXHND_repositoryDirectory}/BashCode/CommandLineParser.bash       || exit -2
source ${EXHND_repositoryDirectory}/BashCode/Version.bash                 || exit -2
source ${EXHND_repositoryDirectory}/BashCode/Setup.bash                   || exit -2
source ${EXHND_repositoryDirectory}/BashCode/NewExercise.bash             || exit -2
source ${EXHND_repositoryDirectory}/BashCode/AuxiliaryFunctions.bash      || exit -2
source ${EXHND_repositoryDirectory}/BashCode/ListUsedExercises.bash       || exit -2
source ${EXHND_repositoryDirectory}/BashCode/ExerciseSelection.bash       || exit -2
source ${EXHND_repositoryDirectory}/BashCode/MainTexFilesCreation.bash    || exit -2
source ${EXHND_repositoryDirectory}/BashCode/ProduceSheet.bash            || exit -2
source ${EXHND_repositoryDirectory}/BashCode/InheritFiles.bash            || exit -2

#------------------------------------------------------------------------------------------------------------------#

printf "\n"
DefineGlobalVariables
ParseCommandLineParameters "$@"
FurtherChecksOnCommandLineOptions

if [ ${EXHND_doSetup} = 'TRUE' ]; then
    MakeSetup
elif [ ${EXHND_importFilesFromTar} = 'TRUE' ]; then
    InheritPastWorkFromTarballSettingUpWorkspace
else
    MakePreliminaryChecks
    if [ ${EXHND_printVersion} = 'TRUE' ]; then
        PrintCodeVersion
    elif [ ${EXHND_produceNewExercise} = 'TRUE' ]; then
        ProduceNewEmptyExerciseAndSolution
    elif [ ${EXHND_listUsedExercises} = 'TRUE' ]; then
        DisplayExerciseLogfile
    elif [ ${EXHND_makeExerciseSheet} = 'TRUE' ]; then
        ProduceExerciseSheet
    elif [ ${EXHND_makeSolutionSheet} = 'TRUE' ]; then
        ProduceSolutionSheet
    elif [ ${EXHND_makeExam} = 'TRUE' ]; then
        ProduceExamSheet
    elif [ ${EXHND_makePresenceSheet} = 'TRUE' ]; then
        ProducePresenceSheet
    elif [ ${EXHND_exportFilesAsTar} = 'TRUE' ]; then
        CreateTarballsToLetWorkBeInherited
    elif [ ${EXHND_importFilesFromTar} = 'TRUE' ]; then
        InheritPastWorkFromTarballSettingUpWorkspace
    else
        PrintWarning "No mutually exclusive option was specified!" "Use the \"--help\" option to get more information!"
    fi
fi

exit 0
