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
EXHND_finalSolutionSheetFolder="${EXHND_invokingDirectory}/FinalSolutionSheets"
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

#Sourcing auxiliary file(s)
source ${EXHND_repositoryDirectory}/AuxiliaryFunctions.sh || exit -2

#Warning that the script is in developement phase!
echo; PrintWarning "Script under developement and in a beta phase! Not everything is guaranteed to work!!"

#Parse command line parameters
ParseCommandLineParameters "$@"

#If user needs exercise template just produce it and exit
if [ ${EXHND_doSetup} = 'TRUE' ]; then
    MakeSetup
    exit 0
elif [ ${EXHND_produceNewExercise} = 'TRUE' ]; then
    ProduceNewEmptyExercise
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

#Compilation
cd ${EXHND_compilationFolder}
pdflatex -interaction=batchmode ${EXHND_mainFilename} >/dev/null 2>&1
if [ $? -ne 0 ]; then
    PrintError "Error occurred in pdflatex compilation!! Files can be found in \"${EXHND_compilationFolder}\" directory to investigate!"
else
    cd ${EXHND_invokingDirectory}
    newPdfFilename="${EXHND_temporaryFolder}/$(basename ${EXHND_mainFilename%.tex})_$(date +%d.%m.%Y_%H%M%S).pdf"
    cp "${EXHND_mainFilename/.tex/.pdf}" "${newPdfFilename}"
    xdg-open "${newPdfFilename}" >/dev/null 2>&1 &
    unset -v 'newPdfFilename'
    rm -r $EXHND_compilationFolder
fi

exit 0

#TODO: 1) Implement a --final option in order to move the produced file (also the .tex
#         in this case) to a separate folder which should be created the first time and
#         which should have a name related to the lecture (e.g. lectureName_semester).
#         An expected name for the folder can be set using the fields in the template.
#         This way the folder can be looked for by the script or created if it does not exist.
#         Having subfolders whose name contains the number of the corresponding sheet is
#         useful because figures might come along with the tex file and the pdf of a given
#         exercise/solution. That being the case, it would be ideal to have a command line
#         option to specify the number for the sheet when the --final option is given.
#         If such an option is not given, the script will automatically set the sheet number
#         to the consecutive one, given the already existing folders in the "lectureName_semester"
#         folder (the command line option is useful because we might want to produce sheet n+1
#         while sheet n is not produced yet). Better having the sheet number both in the
#         subfolder names and in exercises/solution tex files.
#         Think of whether to use this for numbering of sheet.
#      2) Create a log file mechanism in pool of exercises so that the visualization of
#         the list of exercises can distinguish between already used exercises (use
#         colours? Do not show already used exercises?)
#      3) Trap CTRL-C in a nice way: cleaning files/folders. etc. -> DISCUSS
#      4) Give the possibility to the user to create her/his own theme. Implement option
#         to abilitate this and pass the file. This should contain the needed commands
#         (\Heading, etc.) and it should be input in the main tex file. Add description
#         to README file where commands to be provided should be listed. Decide whether we
#         expect to get the full path to the custom theme as an argument to the command line
#         option, or we use a field in localdefs for the path and the command line option to
#         just pass the name (useful also if we will ever have a folder with many available themes).
#      5) Decide how to handle the production of exercise solutions that might not be there when the
#         script is run with the --final option for the exercise sheet production
