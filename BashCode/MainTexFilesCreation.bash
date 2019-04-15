function __static__AddWatermarkToSheet(){
    echo '\usepackage{draftwatermark}'
    echo '\SetWatermarkAngle{90}'
    echo '\SetWatermarkColor[rgb]{0.6,0.6,0.6}'
    echo '\SetWatermarkFontSize{3mm}'
    echo '\SetWatermarkScale{1}'
    echo '\SetWatermarkHorCenter{0.98\paperwidth}'
    echo '\SetWatermarkVerCenter{0.90\paperheight}'
    echo '\SetWatermarkText{Produced with the \,{\color[rgb]{0.4,0.4,0.4}\texttt{ExerciseHandler}}}'
}

function ProduceExerciseTexMainFile(){
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo "\input{$(basename ${EXHND_optionsFilename%.tex})}"
    echo ''
    echo '\documentclass[a4paper]{article}'
    echo ''
    if [ ${EXHND_doNotPrintWatermark} != 'TRUE' ]; then
        __static__AddWatermarkToSheet
    fi
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
    if [ ${EXHND_solutionOfExam} = 'TRUE' ]; then
        echo '  \Heading[false]'
        echo "  \Sheet{exam-solution}[${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]" #subtitle passed to give freedom in customized theme!
    else
        echo '  \Heading'
        echo "  \Sheet{solution-sheet}[${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]" #subtitle passed to give freedom in customized theme!
    fi
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
        score=$(grep '\\begin{exercise}\[.*\]\[[=+0-9]\+\]' ${exercise})
        if [ "${score}" = '' ]; then
            PrintError "Exercise \"$(basename ${exercise})\" seems not to contain a score! Invalid for exam!"; exit -1
        fi
        score=$(grep -o '\[[=+0-9]\+\]$' <<< "${score}" | sed 's/[][]//g') # sed deletes the square brackets
        #Ensures a string with, optionally sum of integers and result (e.g. 1+2+3=6 or simply 6)
        if [[ ! ${score} =~ ^[0-9]+((\+[0-9]+)+=[0-9]+)?$ ]]; then
            PrintInternal "Score \"${score}\" extracted from exercise \"$(basename ${exercise})\" is not valid!"; exit -1
        fi
        allScores+="${score##*=}," #Fine with all formats, i.e. even if no = sign is present
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
        ReadOutExercisesFromFinalSheetLogFile
        seq 1 ${#EXHND_choosenExercises[@]}
    else
        echo $EXHND_exercisesFromPoolAsNumbers | tr , "\n"
    fi
}

function __static__AreExerciseToBeHidden(){
    local toBeHidden
    toBeHidden="$(sed -n 's/^\\newcommand{\\hideExercisesColumnInPresenceSheet}{\(true\|false\)}.*$/\1/p' "${EXHND_texLocaldefsFilename}")"
    if [ ${toBeHidden} != 'true' ] && [ ${toBeHidden} != 'false' ]; then
        PrintError "Unable to read out value of boolean \"\\\\hideExercisesColumnInPresenceSheet\" from \"$(basename "${EXHND_texLocaldefsFilename}")\" file! Invalid for exam!"; exit -1
    elif [ ${toBeHidden} = 'true' ]; then
        return 0
    else
        return 1
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
    if ! __static__AreExerciseToBeHidden; then
        arrayOfExerciseNumbers=( $(__static__ParseExercisesString) ) || { PrintError -c "Final sheet folder needed to produce a presence sheet!"; exit -1; }
        exerciseNumberString=$(printf ",%s" ${arrayOfExerciseNumbers[@]})
        exerciseString=$(printf ",Ex%s" ${arrayOfExerciseNumbers[@]})
    fi
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
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\pagestyle{empty}'
    echo '\begin{document}'
    echo '    \Heading'
    echo "    \Sheet{presence-sheet}[${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo ''
    echo "    \PresenceSheet{$exerciseNumberString}{$exerciseString}{${#arrayOfExerciseNumbers[@]}}{$numberOfStudents}{$students}{${EXHND_isBiWeeklySheet,,}}"
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
