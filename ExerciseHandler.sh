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

#Variables
EXHND_repositoryDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXHND_invokingDirectory="$(pwd)"
EXHND_texLocaldefsFilename='TexLocaldefs.tex'
EXHND_themeFilename='ClassicTheme.tex'
EXHND_exercisePoolFolder='Exercises'
EXHND_solutionPoolFolder='Solutions'
EXHND_finalExerciseSheetFolder='FinalExerciseSheets'
EXHND_finalSolutionSheetFolder='FinalSolutionSheets'
EXHND_temporaryFolder='tmp'
EXHND_exerciseList=(); EXHND_choosenExercises=() #These arrays contain the basenames of the files
EXHND_compilationFolder="TemporaryCompilationFolder"
EXHND_exerciseSheetName="ExerciseSheet"
EXHND_packagesFilename="Packages.tex"
EXHND_definitionsFilename="Definitions.tex"
EXHND_bodyFilename="Document.tex"
EXHND_pdfFolder="Pdf"

#Behaviour options
EXHND_doSetup='FALSE'
EXHND_produceNewExercise='FALSE'

#Sourcing auxiliary file(s)
source ${EXHND_repositoryDirectory}/AuxiliaryFunctions.sh || exit -2

#Warning that the script is in developement phase!
echo; PrintWarning "Script under developement and in a beta phase! Not everything is guaranteed to work!!"

#Parse command line parameters
ParseCommandLineParameters $@

#If user needs exercise template just produce it and exit
if [ ${EXHND_doSetup} = 'TRUE' ]; then
    MakeSetup
    exit 0
elif [ ${EXHND_produceNewExercise} = 'TRUE' ]; then
    ProduceNewEmptyExercise
    exit 0
fi

#Check if template for latex is present, if not or not complete, terminate and warn user
if [ ! -f ${EXHND_texLocaldefsFilename} ]; then
    CreateTexLocaldefsTemplate
    printf "\n\e[38;5;39m \e[1m\e[4mNOTE\e[24m:\e[21m The local definitions file \"${EXHND_texLocaldefsFilename}\""
    printf "has not been found and an empty template to be filled out has been created.\n"
    printf "       Please, provide required information in it and run again this script.\e[0m\n\n"
else
    CheckTexLocaldefsTemplate
fi

#Present list of exercises and ask user which ones she/he wants
LookForExercisesAndMakeList
PrintListOfExercises ${EXHND_exerciseList[@]}
PickupExercises ${EXHND_exerciseList[@]}
CheckChoosenExercises

#TeX part: set up main and sub-files before compilation
[ -d ${EXHND_compilationFolder} ] && mv ${EXHND_compilationFolder} ${EXHND_compilationFolder}_$(date +%d.%m.%Y_%H%M%S)
mkdir ${EXHND_compilationFolder} || { PrintError "Cannot create \"${EXHND_compilationFolder}\"! Aborting..." && exit -2; }
ProduceTexAuxiliaryFile ${EXHND_compilationFolder}/${EXHND_packagesFilename}    "PACKAGES"
ProduceTexAuxiliaryFile ${EXHND_compilationFolder}/${EXHND_definitionsFilename} "DEFINITIONS"
ProduceTexAuxiliaryFile ${EXHND_compilationFolder}/${EXHND_bodyFilename}        "BODY"
CheckTexPackagesFile
CheckTexDefinitionsFile
ProduceTexMainFile      ${EXHND_compilationFolder}/${EXHND_exerciseSheetName}.tex

#Compilation
cd ${EXHND_compilationFolder}
pdflatex -interaction=batchmode ${EXHND_exerciseSheetName}.tex >/dev/null 2>&1
if [ $? -ne 0 ]; then
    PrintError "Error occurred in pdflatex compilation!! Files can be found in \"${EXHND_compilationFolder}\" directory to investigate!"
else
    cd ${EXHND_invokingDirectory}
    mkdir -p ${EXHND_pdfFolder}
    newPdfFilename=${EXHND_exerciseSheetName}_$(date +%d.%m.%Y_%H%M%S)
    cp ${EXHND_compilationFolder}/${EXHND_exerciseSheetName}.pdf ${EXHND_pdfFolder}/${newPdfFilename}
    xdg-open ${EXHND_pdfFolder}/${newPdfFilename} >/dev/null 2>&1 &
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
#      4) Implement an option to give exercise numbers and therefore skip interactive step!
#         Maybe allow ranges in specifying the numbers!
#      5) DISCUSS about latex commands: which arguments are needed? How to set them?
#         For example, put in localdefs the hand in day of the week? Make command line option?!
#         For the "subtitle" of the exercise sheet that can range from "To be handed in on
#         DAYOFTHEWEEK" to "Solution given on DD/MM/YY" it would be ideal to deal with two
#         arguments. The first is the "wording" which is surely common to any sheet, while
#         the second is the time specification that might change. For the first it is ideal
#         to have a corresponding field in the localdefs and no command line option. For the
#         second the interplay between a field in localdefs and a command line option could work.
#      6) Give the possibility to the user to create her/his own theme. Implement option
#         to abilitate this and pass the file. This should contain the needed commands
#         (\Heading, etc.) and it should be input in the main tex file. Add description
#         to README file where commands to be provided should be listed. Decide whether we
#         expect to get the full path to the custom theme as an argument to the command line
#         option, or we use a field in localdefs for the path and the command line option to
#         just pass the name (useful also if we will ever have a folder with many available themes).
#      7) Decide how to handle the production of exercise solutions that might not be there when the
#         script is run with the --final option for the exercise sheet production
