#!/bin/bash

#-------------------------------------------------------------------------------------------------#
#      ____ _  __ ____ ___   _____ ____ ____ ____      __ __ ___    _  __ ___   __    ____ ___    #
#     / __/| |/_// __// _ \ / ___//  _// __// __/     / // // _ |  / |/ // _ \ / /   / __// _ \   #
#    / _/ _>  < / _/ / , _// /__ _/ / _\ \ / _/      / _  // __ | /    // // // /__ / _/ / , _/   #
#   /___//_/|_|/___//_/|_| \___//___//___//___/     /_//_//_/ |_|/_/|_//____//____//___//_/|_|    #
#                                                                                                 #
#-------------------------------------------------------------------------------------------------#
#                                                                                                 #
#         Copyright (c) 2016-2017 Alessandro Sciarra: sciarra@th.physik.uni-frankfurt.de          #
#         Copyright (c) 2016        Francesca Cuteri:  cuteri@th.physik.uni-frankfurt.de          #
#                                                                                                 #
#-------------------------------------------------------------------------------------------------#

#Global internal variables
EXHND_repositoryDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXHND_themeFilename="${EXHND_repositoryDirectory}/ClassicTheme.tex"
EXHND_invokingDirectory="$(pwd)"
EXHND_texLocaldefsFilename="${EXHND_invokingDirectory}/TexLocaldefs.tex"
EXHND_exercisePoolFolder="${EXHND_invokingDirectory}/Exercises"
EXHND_solutionPoolFolder="${EXHND_invokingDirectory}/Solutions"
EXHND_finalExerciseSheetFolder="${EXHND_invokingDirectory}/FinalExerciseSheets"
EXHND_exercisesLogFilename="${EXHND_invokingDirectory}/.exercises.log"
EXHND_finalSolutionSheetFolder="${EXHND_invokingDirectory}/FinalSolutionSheets"
EXHND_figuresFolder="${EXHND_invokingDirectory}/Figures"
EXHND_temporaryFolder="${EXHND_invokingDirectory}/tmp"
EXHND_compilationFolder="${EXHND_temporaryFolder}/TemporaryCompilationFolder"
EXHND_packagesFilename="${EXHND_compilationFolder}/Packages.tex"
EXHND_definitionsFilename="${EXHND_compilationFolder}/Definitions.tex"
EXHND_bodyFilename="${EXHND_compilationFolder}/Document.tex"
EXHND_mainFilename="${EXHND_compilationFolder}/ExerciseSheet.tex"
EXHND_exerciseList=(); EXHND_choosenExercises=() #These arrays contain the basenames of the files

#Variables with input from user
EXHND_exerciseSheetSubtitlePostfix=''
EXHND_exerciseSheetNumber=''
EXHND_exercisesFromPoolAsNumbers=''

#Behaviour options
EXHND_doSetup='FALSE'
EXHND_produceNewExercise='FALSE'
EXHND_listUsedExercises='FALSE'
EXHND_isFinal='FALSE'
EXHND_displayAlreadyUsedExercises='FALSE'

#Sourcing auxiliary file(s)
source ${EXHND_repositoryDirectory}/AuxiliaryFunctions.sh || exit -2

#Warning that the script is in developement phase!
echo; PrintWarning "Script under developement and in a beta phase! Not everything is guaranteed to work!!"

#Check that the script is invoked from a probably correct position
if IsInvokingPositionWrong; then
    PrintError "Invoking position of the Exercise Handler seems to be wrong! Run the setup to create missing files/folders! Aborting..."; exit -1
fi

#Parse command line parameters
ParseCommandLineParameters "$@"

#If user needs exercise template just produce it and exit
if [ ${EXHND_doSetup} = 'TRUE' ]; then
    MakeSetup
    exit 0
elif [ ${EXHND_produceNewExercise} = 'TRUE' ]; then
    ProduceNewEmptyExercise
    exit 0
elif [ ${EXHND_listUsedExercises} = 'TRUE' ]; then
    DisplayExerciseLogfile
    exit 0
fi

#If user did not give number for the sheet, set it
if [ "$EXHND_exerciseSheetNumber" = '' ]; then
    EXHND_exerciseSheetNumber=$(DetermineSheetNumber)
fi

#Check if template for latex is present, if not or not complete, terminate and warn user
if [ ! -f ${EXHND_texLocaldefsFilename} ]; then
    CreateTexLocaldefsTemplate
    printf "\n\e[38;5;39m \e[1m\e[4mNOTE\e[24m:\e[21m The local definitions file \"${EXHND_texLocaldefsFilename}\""
    printf "has not been found and an empty template to be filled out has been created.\n"
    printf "       Please, provide required information in it and run again this script.\e[0m\n\n"
    exit 0
else
    CheckTexLocaldefsTemplate
fi

#Present list of exercises and ask user which ones she/he wants
LookForExercisesAndMakeList
if [ "$EXHND_exercisesFromPoolAsNumbers" = '' ]; then
    PrintListOfExercises ${EXHND_exerciseList[@]}
    PickupExercises ${EXHND_exerciseList[@]}
else
    EXHND_exercisesFromPoolAsNumbers=( $(GetArrayFromCommaSeparatedListOfIntegersAcceptingRanges ${EXHND_exercisesFromPoolAsNumbers}) )
    if IsAnyExerciseNotExisting ${#EXHND_exerciseList[@]} ${EXHND_exercisesFromPoolAsNumbers[@]}; then
        PrintError "Some of the chosen exercises are not existing! Aborting..."; exit 0
    else
        FillChoosenExercisesArray "${EXHND_exercisesFromPoolAsNumbers[*]}" "${EXHND_exerciseList[*]}" #https://stackoverflow.com/a/16628100
    fi
fi
CheckChoosenExercises

#TeX part: set up main and sub-files before compilation
CreateTemporaryCompilationFolder
ProduceTexAuxiliaryFiles
CheckTexPackagesFile
CheckTexDefinitionsFile
ProduceTexMainFile
MakeCompilationInTemporaryFolder
if [ $EXHND_isFinal = 'FALSE' ]; then
    MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder
else
    MoveExerciseSheetFilesToFinalFolderOpenItAndRemoveCompilationFolder
    UpdateExerciseLogfile
fi

exit 0

#TODO: 1) Trap CTRL-C in a nice way: cleaning files/folders. etc. -> DISCUSS
#      2) Give the possibility to the user to create her/his own theme. Implement option
#         to abilitate this and pass the file. This should contain the needed commands
#         (\Heading, etc.) and it should be input in the main tex file. Add description
#         to README file where commands to be provided should be listed. Decide whether we
#         expect to get the full path to the custom theme as an argument to the command line
#         option, or we use a field in localdefs for the path and the command line option to
#         just pass the name (useful also if we will ever have a folder with many available themes).
#      3) Decide how to handle the production of exercise solutions that might not be there when the
#         script is run with the --final option for the exercise sheet production
#      4) Add option to remove final sheet updating the exercise log file
#      5) Add option to force production of already existing final sheet updating exercise log file
