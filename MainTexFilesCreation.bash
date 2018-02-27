function ProduceExerciseTexMainFile(){
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo "\input{$(basename ${EXHND_optionsFilename%.tex})}"
    echo ''
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo "\input{$(basename ${EXHND_packagesFilename%.tex})}"
    echo ''
    echo "\input{$(basename ${EXHND_definitionsFilename%.tex})}"
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet{exercise-sheet}[${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo '  %Exercises'
    echo "  \input{$(basename ${EXHND_bodyFilename%.tex})}"
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
    echo "\input{$(basename ${EXHND_optionsFilename%.tex})}"
    echo ''
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo "\input{$(basename ${EXHND_packagesFilename%.tex})}"
    echo ''
    echo "\input{$(basename ${EXHND_definitionsFilename%.tex})}"
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet{solution-sheet}[${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]" #subtitle passed to give freedom in customized theme!
    echo '  %Exercises'
    echo "  \input{$(basename ${EXHND_bodyFilename%.tex})}"
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function __static__GetPointsFromExercises(){
    local exercise score allScores; allScores=''
    for exercise in "${EXHND_filesToBeUsedGlobalPath[@]}"; do
        if [ $(grep -c '\\begin{solution}' ${exercise}) -ne 0 ]; then
            continue
        fi
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
    echo "\input{$(basename ${EXHND_optionsFilename%.tex})}"
    echo ''
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo "\input{$(basename ${EXHND_packagesFilename%.tex})}"
    echo ''
    echo "\input{$(basename ${EXHND_definitionsFilename%.tex})}"
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading[false]'
    echo "  \Sheet{exam}[][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo "  \ExamCoverPage{${#EXHND_choosenExercises[@]}}{${exerciseScores}}"
    echo '  %Exercises'
    echo "  \input{$(basename ${EXHND_bodyFilename%.tex})}"
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function __static__ParseExercisesString(){
    if [[ $EXHND_exercisesFromPoolAsNumbers = "" ]]; then
        ReadOutExercisesFromFinalExerciseSheetLogFile
        seq 1 ${#EXHND_choosenExercises[@]}
    elif [[ $EXHND_exercisesFromPoolAsNumbers =~ ^[1-9][0-9]*([.][1-9][0-9]*)*([,][1-9][0-9]*([.][1-9][0-9]*)*)*$ ]]; then
        echo $EXHND_exercisesFromPoolAsNumbers | tr , "\n"
    else
        printf "\e[38;5;9m The value of the option \e[1m-n\e[21m was not correctly specified for the creation of the Presence sheet!\n"; exit -1
    fi
}

function ProducePresenceSheetTexMainFile(){
    local students numberOfStudents arrayOfExerciseNumbers exerciseNumberString exerciseString
    students=$(awk 'BEGIN {ORS=","}$0 ~ /^[[:space:]]*$/{next}{ print $0 }' $EXHND_listOfStudentsFilename)
    numberOfStudents=$(grep -o ',' <<< "$students" | wc -l)
    thresholdNumberOfStudents=15
    if [ $numberOfStudents -gt $(($thresholdNumberOfStudents-2)) ]; then
        numberOfStudents=$(($numberOfStudents+2))
    else
        numberOfStudents=$thresholdNumberOfStudents
    fi
    arrayOfExerciseNumbers=($(__static__ParseExercisesString))
    exerciseNumberString=$(printf ",%s" ${arrayOfExerciseNumbers[@]})
    exerciseString=$(printf ",Ex%s" ${arrayOfExerciseNumbers[@]})
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo "\input{$(basename ${EXHND_optionsFilename%.tex})}"
    echo ''
    echo '\documentclass[10pt,a4paper]{article}'
    echo ''
    echo "\input{$(basename ${EXHND_packagesFilename%.tex})}"
    echo ''
    echo "\input{$(basename ${EXHND_definitionsFilename%.tex})}"
    echo ''
    echo '\pagestyle{empty}'
    echo '\begin{document}'
    echo '    \Heading'
    echo "    \Sheet{presence-sheet}[${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo ''
    echo "    \PresenceSheet{$exerciseNumberString}{$exerciseString}{${#arrayOfExerciseNumbers[@]}}{$numberOfStudents}{$students}"
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
