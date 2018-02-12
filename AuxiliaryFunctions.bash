function GetFinalExerciseSheetFolderName(){
    if [ "$1" = '' ]; then
        echo ${EXHND_finalExerciseSheetFolder}/$(basename ${EXHND_mainFilename%.tex})_
    else
        echo ${EXHND_finalExerciseSheetFolder}/$(basename ${EXHND_mainFilename%.tex})_$(printf "%02d" $1)
    fi
}
