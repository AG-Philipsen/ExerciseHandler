function ProduceExerciseTexMainFile(){
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\input{Options}'
    echo ''
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet[][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceSolutionTexMainFile(){
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\input{Options}'
    echo ''
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet[Solution of exercise sheet][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]" #subtitle passed to give freedom in customized theme!
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function __static__GetPointsFromExercises(){
    local exercise score allScores; allScores=''
    for exercise in "${EXHND_filesToBeUsedGlobalPath[@]}"; do
        score=$(grep '\\begin{exercise}\[.*\]\[[0-9]\+\]' ${exercise})
        if [ "${score}" = '' ]; then
            PrintError "Exercise \"$(basename ${exercise})\" seems not to contain a score! Invalid for exam!"; exit -1
        fi
        score=$(grep -o '\[[0-9]\+\]$' <<< "${score}" | grep -o '[0-9]\+')
        if [[ ! ${score} =~ ^[0-9]+$ ]]; then
            PrintInternal "Error extracting score from exercise \"$(basename ${exercise})\"!"; exit -1
        fi
        allScores+="${score},"
    done
    echo ${allScores%?}
}

function ProduceExamTexMainFile(){
    #Single exercise warning
    if [ $(basename ${EXHND_themeFilename}) = 'ClassicTheme.tex' ] && [ ${#EXHND_choosenExercises[@]} -eq 1 ]; then
        PrintWarning "Having only one exercise in the exam leads to an extra empty line in cover page table -> https://tex.stackexchange.com/a/373213"
    fi
    #Get scores
    local exerciseScores; exerciseScores=$(__static__GetPointsFromExercises) || { PrintError "Unable to recover scores from exercises in exam mode!" && exit -1; }
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\input{Options}'
    echo ''
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading[false]'
    echo "  \Sheet[Exam][][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo "  \ExamCoverPage{${#EXHND_choosenExercises[@]}}{${exerciseScores}}"
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
function __static__GetStudents(){
    echo "$(awk 'BEGIN {ORS=","}$0 ~ /^[[:space:]]*$/{next}{ print $0 }' $EXHND_listOfStudentsFilename)"
}

function __static__GetNumberOfStudents(){
    echo "$(grep -o ',' <<< "$1" | wc -l)"
}

function __static__ParseExercisesString(){
    if [[ $EXHND_exercisesFromPoolAsNumbers = "" ]]; then
        ReadOutExercisesFromFinalExerciseSheetLogFile
        echo "$(seq 1 ${#EXHND_choosenExercises[@]})"
    elif [[ $EXHND_exercisesFromPoolAsNumbers =~ ^[1-9][0-9]*([.][1-9][0-9]*)*([,][1-9][0-9]*([.][1-9][0-9]*)*)*$ ]]; then
        echo $EXHND_exercisesFromPoolAsNumbers | tr , "\n"
    else
        printf "\e[38;5;9m The value of the option \e[1m-n\e[21m was not correctly specified for the creation of the Presence sheet!\n"; exit -1
    fi
}

function ProducePresenceSheetTexMainFile(){
    local students=$(__static__GetStudents)
    local numberOfStudents=$(__static__GetNumberOfStudents $students)
    local arrayOfExerciseNumbers=($(__static__ParseExercisesString))
    local exerciseString=$(echo $(printf ",Ex%s" ${arrayOfExerciseNumbers[@]}))
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\documentclass[10pt,a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo ''
    echo '\begin{document}'
    echo '    \Heading'
    echo "    \Sheet[Presence sheet][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo ''
    echo "    \PresenceSheet{$EXHND_exercisesFromPoolAsNumbers}{$exerciseString}{${#arrayOfExerciseNumbers[@]}}{$numberOfStudents}{$students}"
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
