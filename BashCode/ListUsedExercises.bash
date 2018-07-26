function __static__PrintExerciseNamesOfSingleExerciseSheet(){
    local label sheetNumber givenList exercise counter
    label="$1"; sheetNumber=$2; shift 2
    givenList=( $@ )
    printf "\e[38;5;48m \e[1m\e[4m${label} ${sheetNumber}\e[24m:\e[0m\n\n"
    counter=0
    for exercise in ${givenList[@]}; do
        ((counter++))
        printf "\e[38;5;38m    $counter) %s\e[0m\n" ${exercise}
    done
    printf "\n"
}


function DisplayExerciseLogfile(){
    if [ "$(ls -A ${EXHND_finalExerciseSheetFolder})" = '' ] && [ "$(ls -A ${EXHND_finalExamSheetFolder})" = '' ]; then
        PrintInfo "No exercise sheet or exam to be displayed!"
        return
    fi
    local folder sheetNumber listOfExercises
    #Exercise sheets
    if [ "$(ls -A ${EXHND_finalExerciseSheetFolder})" != '' ]; then
        for folder in $(GetFinalSheetFolderGlobalPathWithoutNumber 'EXERCISE')*/; do
            if [ ! -f ${folder}${EXHND_exercisesLogFilename} ]; then
                PrintWarning "Exercise log file not found in \"${folder}\" folder, skipping it!"
                continue
            fi
            sheetNumber=$(awk 'END{print $1}' ${folder}${EXHND_exercisesLogFilename})
            listOfExercises=( $(awk -v sheet="${sheetNumber}" '$1==sheet{print $2}' ${folder}${EXHND_exercisesLogFilename}) )
            __static__PrintExerciseNamesOfSingleExerciseSheet 'Exercise Sheet' ${sheetNumber} ${listOfExercises[@]}
        done
    fi
    #Exams sheets
    if  [ "$(ls -A ${EXHND_finalExamSheetFolder})" != '' ]; then
        for folder in $(GetFinalSheetFolderGlobalPathWithoutNumber 'EXAM')*/; do
            if [ ! -f ${folder}${EXHND_examLogFilename} ]; then
                PrintWarning "Exam log file not found in \"${folder}\" folder, skipping it!"
                continue
            fi
            sheetNumber=$(awk 'END{print $1}' ${folder}${EXHND_examLogFilename})
            listOfExercises=( $(awk -v sheet="${sheetNumber}" '$1==sheet{print $2}' ${folder}${EXHND_examLogFilename}) )
            __static__PrintExerciseNamesOfSingleExerciseSheet 'Exam' ${sheetNumber} ${listOfExercises[@]}
        done
    fi
}
