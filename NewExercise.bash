function ProduceNewEmptyExercise(){
    printf "\e[38;5;207m\n Please, insert the exercise filename: \e[0m\e[s"
    local newExerciseFilename
    while read newExerciseFilename; do
        [ "${newExerciseFilename}" = '' ] && printf "\e[u\e[1A" && continue
        if [[ ! ${newExerciseFilename} =~ [.]tex$ ]]; then
            newExerciseFilename+=".tex"
        fi
        if [ -f ${EXHND_exercisePoolFolder}/${newExerciseFilename} ]; then
            printf "\n\e[1;38;5;202m File \"${newExerciseFilename}\" already existing!\e[21m\e[38;5;11m Please, provide a different name: \e[0m\e[s"
            continue
        else
            echo; break
        fi
    done
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_exercisePoolFolder}/${newExerciseFilename}
    echo -e '%__BEGIN_PACKAGES__%\n\n%__END_PACKAGES__%\n\n\n'
    echo -e '%__BEGIN_DEFINITIONS__%\n\n%__END_DEFINITIONS__%\n\n\n'
    echo -e '%__BEGIN_BODY__%'
    echo -e '\\begin{exercise}[]\n'
    echo -e '\\end{exercise}'
    echo -e '%__END_BODY__%\n\n\n'
    #Restore standard output
    exec 1>&3
}
