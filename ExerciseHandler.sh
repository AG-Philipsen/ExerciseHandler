#!/bin/bash

#----------------------------------------------------------------------------------------#
#      ____ _  __ ____ ___   _____ ____ ____ ____      __  ___ ___    __ __ ____ ___     #
#     / __/| |/_// __// _ \ / ___//  _// __// __/     /  |/  // _ |  / //_// __// _ \    #
#    / _/ _>  < / _/ / , _// /__ _/ / _\ \ / _/      / /|_/ // __ | / ,<  / _/ / , _/    #
#   /___//_/|_|/___//_/|_| \___//___//___//___/     /_/  /_//_/ |_|/_/|_|/___//_/|_|     #
#                                                                                        #   
#----------------------------------------------------------------------------------------#
#                                                                                        #
#       Copyright (c) 2016 Alessandro Sciarra: sciarra@th.physik.uni-frankfurt.de        #
#                            Francesca Cuteri:  cuteri@th.physik.uni-frankfurt.de        #
#                                                                                        #
#----------------------------------------------------------------------------------------#

#Variables
REPOSITORY_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INVOKING_DIRECTORY="$(pwd)"
TEX_LOCALDEFS_FILENAME="TexLocaldefs.tex"
EXERCISE_POOL_FOLDER="Exercises"
EXERCISE_LIST=(); CHOOSEN_EXERCISES=() #These arrays contain the basenames of the files
COMPILATION_FOLDER="TemporaryCompilationFolder"
EXERCISE_SHEET_NAME="ExerciseSheet"
PACKAGES_TEX_FILE="Packages.tex"
#USER_PREAMBLE_TEX_FILE="Preamble.tex"
DEFINITIONS_TEX_FILE="Definitions.tex"
DOCUMENT_TEX_FILE="Document.tex"
PDF_FOLDER="Pdf"
PRODUCE_NEW_EXERCISE='FALSE'

#Sourcing auxiliary file(s)
source $REPOSITORY_DIRECTORY/AuxiliaryFunctions.sh || exit -2

#Warning that the script is in developement phase!
PrintWarning "Script under developement and in a beta phase! Not everything is guaranteed to work!!"

#Parse command line parameters
ParseCommandLineParameters $@

#If user needs exercise template just produce it and exit
[ $PRODUCE_NEW_EXERCISE = 'TRUE' ] && ProduceNewEmptyExercise && exit 0

#Check if template for latex is present, if not or not complete, terminate and warn user
if [ ! -f $TEX_LOCALDEFS_FILENAME ]; then
    CreateTexLocaldefsTemplate
    printf "\n\e[38;5;39m \e[1m\e[4mNOTE\e[24m:\e[21m The local definitions file \"$TEX_LOCALDEFS_FILENAME\""
    printf "has not been found and an empty template to be filled out has been created.\n"
    printf "       Please, provide required information in it and run again this script.\e[0m\n\n"
else
    CheckTexLocaldefsTemplate
fi

#Present list of exercises and ask user which ones she/he wants
LookForExercisesAndMakeList
PrintListOfExercises ${EXERCISE_LIST[@]}
PickupExercises ${EXERCISE_LIST[@]}
CheckChoosenExercises

#TeX part: set up main and sub-files before compilation
[ -d $COMPILATION_FOLDER ] && mv $COMPILATION_FOLDER ${COMPILATION_FOLDER}_$(date +%d.%m.%Y_%H%M%S)
mkdir $COMPILATION_FOLDER || { PrintError "Cannot create \"$COMPILATION_FOLDER\"! Aborting..." && exit -2; }
ProduceTexAuxiliaryFile $COMPILATION_FOLDER/$PACKAGES_TEX_FILE    "PACKAGES"
ProduceTexAuxiliaryFile $COMPILATION_FOLDER/$DEFINITIONS_TEX_FILE "DEFINITIONS"
ProduceTexAuxiliaryFile $COMPILATION_FOLDER/$DOCUMENT_TEX_FILE    "BODY"
CheckTexPackagesFile
CheckTexDefinitionsFile
ProduceTexMainFile      $COMPILATION_FOLDER/${EXERCISE_SHEET_NAME}.tex

#Compilation
cd $COMPILATION_FOLDER
pdflatex -interaction=batchmode ${EXERCISE_SHEET_NAME}.tex >/dev/null 2>&1
if [ $? -ne 0 ]; then
    PrintError "Error occurred in pdflatex compilation!! No file will be removed from \"$COMPILATION_FOLDER\" directory!"
else
    cd $INVOKING_DIRECTORY
    mkdir -p $PDF_FOLDER
    NEW_PDF_FILENAME=${EXERCISE_SHEET_NAME}_$(date +%d.%m.%Y_%H%M%S)
    cp $COMPILATION_FOLDER/${EXERCISE_SHEET_NAME}.pdf $PDF_FOLDER/$NEW_PDF_FILENAME
    xdg-open $PDF_FOLDER/$NEW_PDF_FILENAME >/dev/null 2>&1 &
    rm -r $COMPILATION_FOLDER
fi

exit 0

#NOTE: Ideally this git should be only a collection of tools. The user should
#      elsewhere create one or two localdefs files and then call this file from there.
#      Therefore, this script should look for the file with the localdefs from where it
#      is run (give default names and maybe make an option to change their name). 
#      If this file it is not found, a template should be created and the user warned!
#      Flow of the script:
#      1) Check template                                                DONE
#      2) Ask user for exercises                                        DONE
#      3) Create main file that basically will input:                   DONE
#           Packages.tex  Preamble.tex  Localdefs.tex  Document.tex     DONE
#      4) Create each of the files needed
#           Packages.tex                                                DONE
#           Preamble.tex                                                DONE
#           Localdefs.tex                                               DONE
#           Document.tex                                                DONE
#      5) Compile main file (in separate folder)                        DONE
#      6) Delete aux files if everything is fine (and open pdf!?).      DONE
#
#TODO: 1) Think about possible bunch of packages always used. Make them up to the user
#         in a possible file that the user can create locally!?
#         Ingredients needed:
#          - Parser for Exercise file (extraction of user packages, commands)
#          - Logic with user variables for Preamble commands (e.g. lecture, prof, etc.)
#      2) Implement main part where the exercise are processed, the Sheet.tex
#         file is created, compiled and deleted (if everything fine, only .pdf should
#         be kept; maybe do compilation in separate folder so that the user can
#         investigate in case!?)
#      3) Implement a --final option in order to move the produced file (also the .tex
#         in this case) to a separate folder which should be created the first time and
#         which should have a name related to the lecture (e.g. lectureName_semester).
#         Think of whether to use this for numbering of sheet.
#      4) Create a log file mechanism in pool of exercises so that the visualization of
#         the list of exercises can distinguish between already used exercises (use
#         colours? Do not show already used exercises?)
#      5) Trap CTRL-C in a nice way: cleaning files/folders. etc. -> DISCUSS
#      6) Implement an option to give exercise numbers and therefore skip interactive step!
#      7) DISCUSS about latex commands: which arguments are needed? How to set them?
#         For example, put in localdefs the hand in day of the week? Make command line option?!
#      8) Give the possibility to the user to create her/his own theme. Implement option
#         to abilitate this and pass the file. This should contain the needed commands
#         (\Heading, etc.) and it should be input in the main tex file. Add description
#         to README file where commands to be provided should be listed.
