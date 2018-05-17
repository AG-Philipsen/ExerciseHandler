function __static__ProduceTemplate(){
    local environment outputFile
    environment="$1"; outputFile="$2"
    #Redirect standard output to file
    exec 3>&1 1>"${outputFile}"
    printf '%s\n\n%s\n\n\n\n'   '%__BEGIN_OPTIONS__%'      '%__END_OPTIONS__%'
    printf '%s\n\n%s\n\n\n\n'   '%__BEGIN_PACKAGES__%'     '%__END_PACKAGES__%'
    printf '%s\n\n%s\n\n\n\n'   '%__BEGIN_DEFINITIONS__%'  '%__END_DEFINITIONS__%'
    printf '%s\n'               '%__BEGIN_BODY__%'
    printf '\\begin{%s}\n'  "${environment}"
    if [ ${environment} = 'solution' ]; then
        printf '    \\makeatletter\n'
        printf '        \\EH@Translate{solution-not-provided}.\n'
        printf '    \\makeatother.\n'
    else
        printf '\n'
    fi
    printf '\\end{%s}\n'        "${environment}"
    printf '%s\n\n\n\n'         '%__END_BODY__%'
    #Restore standard output
    exec 1>&3
}


function ProduceNewEmptyExerciseAndSolution(){
    local newExerciseGlobalPath newSolutionGlobalPath
    if [ "${EXHND_newExerciseFilename}" = '' ]; then
        printf "\e[38;5;207m Please, insert the exercise filename: \e[0m\e[s"
        while read newExerciseGlobalPath; do
            [ "${newExerciseGlobalPath}" = '' ] && printf "\e[u" && continue
            echo; break
        done
    else
        newExerciseGlobalPath="${EXHND_newExerciseFilename}"
    fi
    if [[ ! ${newExerciseGlobalPath} =~ [.]tex$ ]]; then
        newExerciseGlobalPath+=".tex"
    fi
    newSolutionGlobalPath="${EXHND_solutionPoolFolder}/${newExerciseGlobalPath}"
    newExerciseGlobalPath="${EXHND_exercisePoolFolder}/${newExerciseGlobalPath}"
    #Create exercise
    if [ -f "${newExerciseGlobalPath}" ]; then
        PrintWarning "Exercise \"$(basename "${newExerciseGlobalPath}")\" already existing. Creating corresponding solution..."
    else
        __static__ProduceTemplate 'exercise' "${newExerciseGlobalPath}"
        PrintInfo "New exercise \"$(basename "${newExerciseGlobalPath}")\" template was successfully created."
    fi
    #Create solution
    if [ -f "${newSolutionGlobalPath}" ]; then
        PrintWarning "Solution \"$(basename "${newSolutionGlobalPath}")\" already existing, not created."
    else
        __static__ProduceTemplate 'solution' "${newSolutionGlobalPath}"
        PrintInfo "New solution \"$(basename "${newSolutionGlobalPath}")\" template was successfully created."
    fi
}
