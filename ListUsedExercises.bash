function __static__PrintExerciseNamesOfSingleExerciseSheet(){
    local sheetNumber givenList exercise counter
    sheetNumber=$1; shift
    givenList=( $@ )
    printf "\e[38;5;48m \e[1m\e[4mExercise Sheet ${sheetNumber}\e[24m:\e[0m\n\n"
    counter=0
    for exercise in ${givenList[@]}; do
        ((counter++))
        printf "\e[38;5;38m    $counter) %s\e[0m\n" ${exercise}
    done
    printf "\n"
}


function DisplayExerciseLogfile(){
    if [ "$(ls -A ${EXHND_finalExerciseSheetFolder})" = '' ]; then
        PrintInfo "No exercise to be displayed!"
        return
    fi
    local folder sheetNumber listOfExercises
    for folder in $(GetFinalExerciseSheetFolderName)*/; do
        if [ ! -f ${folder}${EXHND_exercisesLogFilename} ]; then
            PrintWarning "Exercise log file not found in \"${folder}\" folder, skipping it!"
            continue
        fi
        sheetNumber=$(awk 'END{print $1}' ${folder}${EXHND_exercisesLogFilename})
        listOfExercises=( $(awk -v sheet="${sheetNumber}" '$1==sheet{print $2}' ${folder}${EXHND_exercisesLogFilename}) )
        __static__PrintExerciseNamesOfSingleExerciseSheet ${sheetNumber} ${listOfExercises[@]}
    done
}
