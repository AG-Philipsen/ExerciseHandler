function ParseCommandLineParameters(){
    declare -rA mapOptions=( ['-h']='--help'
                             ['-U']='--setup'
                             ['-N']='--newExercise'
                             ['-E']='--makeExerciseSheet'
                             ['-S']='--makeSolutionSheet'
                             ['-P']='--makePresenceSheet'
                             ['-X']='--makeExam'
                             ['-L']='--listUsedExercises'
                             ['-T']='--exportFilesAsTar'
                             ['-I']='--importFilesFromTar'
                             ['-V']='--version'
                             ['-a']='--showAllExercises'
                             ['-e']='--exercises'
                             ['-p']='--sheetSubtitlePostfix'
                             ['-s']='--showAlsoSolutions'
                             ['-m']='--ofExam'
                             ['-n']='--sheetNumber'
                             ['-f']='--final'
                             ['-x']='--fix'
                             ['-b']='--biWeeklySheet')
    local mutuallyExclusiveOptionsPassed; mutuallyExclusiveOptionsPassed=()
    #The following if is important because, if there are no command line options,
    #the readarray would still return an array with one empty option which would
    #then trigger an error in the parser (it would enter the while instead of skipping it)
    if [ $# -gt 0 ]; then
        local commandLineOptions
        readarray -t commandLineOptions <<< "$(__static__SplitCombinedShortOptionsInSingleOptions "$@")"
        readarray -t commandLineOptions <<< "$(__static__ReplaceShortOptionsWithLongOnes "${commandLineOptions[@]}")"
        #Reset function arguments
        set -- "${commandLineOptions[@]}"
    fi
    #Additional logic to distinguish between primary and secondary options
    local primaryOptions; primaryOptions=( '-U' '-N' '-E' '-P' '-S' '-X' '-L' '-T' '-I' '-V' ) #To keep associative array "ordered"
    declare -rA secondaryToPrimaryOptionsMapping=([${primaryOptions[0]}]=''
                                                  [${primaryOptions[1]}]=''
                                                  [${primaryOptions[2]}]='-a -e -p -s -n -f -x'
                                                  [${primaryOptions[3]}]='-e -n -p -b'
                                                  [${primaryOptions[4]}]='-m -e -n -f -x'
                                                  [${primaryOptions[5]}]='-e -n -s -f -x'
                                                  [${primaryOptions[6]}]=''
                                                  [${primaryOptions[7]}]=''
                                                  [${primaryOptions[8]}]=''
                                                  [${primaryOptions[9]}]='' )
    #Parse options: here only long options are used
    while [ $# -gt 0 ]; do
        case $1 in
            --help )
                __static__PrintHelp
                exit 0
                shift ;;
            --setup )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_doSetup="TRUE"
                shift;;
            --newExercise )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_produceNewExercise='TRUE'
                if [ "$2" != '' ] && [[ ! $2 =~ ^- ]]; then
                    EXHND_newExerciseFilename="$2"
                    shift
                fi
                shift ;;
            --makeExerciseSheet )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makeExerciseSheet='TRUE'
                shift ;;
            --makeSolutionSheet )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makeSolutionSheet='TRUE'
                shift ;;
            --makePresenceSheet )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makePresenceSheet='TRUE'
                if [ "$2" != '' ] && [[ ! $2 =~ ^- ]]; then
                    EXHND_listOfStudentsFilename="${EXHND_presenceSheetFolder}/$2"
                    shift
                fi
                shift ;;
            --makeExam )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makeExam='TRUE'
                shift ;;
            --listUsedExercises )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_listUsedExercises='TRUE'
                shift ;;
            --exportFilesAsTar )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_exportFilesAsTar='TRUE'
                if [ "$2" != '' ] && [[ ! $2 =~ ^- ]]; then
                    EXHND_tarballPrefix="$2"
                    shift
                fi
                shift ;;
            --importFilesFromTar )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_importFilesFromTar='TRUE'
                if [ "$2" != '' ] && [[ ! $2 =~ ^- ]]; then
                    EXHND_tarballFilename="$2"
                    if [[ ! ${EXHND_tarballFilename} =~ ${EXHND_tarballExerciseHandlerPostfix}$ ]]; then
                        PrintError "The expected tarball file must end with \"${EXHND_tarballExerciseHandlerPostfix}\"."; exit -1
                    fi
                    shift
                else
                    PrintError "The value of the option \"$1\" was not correctly specified!"; exit -1
                fi
                shift ;;
            --version )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_printVersion='TRUE'
                shift ;;

            --exercises )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                #To avoid headache and escape many characters it is sometimes better to put the
                #regular expression into a variable and then use [[ ... =~ $var ]]. Nevertheless
                #some peculiar POSIX regex rules have to be still considered like that to match
                #a literal - one has to put it at the beginning or at the end of the group [].
                #Read https://stackoverflow.com/a/18710850 or 'man 7 regex' for more information!
                local regExNotPresenceSheet regExPresenceSheet
                regExNotPresenceSheet='^[1-9][0-9]*([,-][1-9][0-9]*)*$'
                regExPresenceSheet='^[-a-zA-Z0-9,. ()]+$'
                if [[ ${mutuallyExclusiveOptionsPassed[@]: -1} = '--makeSolutionSheet' ]]; then
                    EXHND_showAlsoExercises='TRUE'
                    shift
                elif [[ ${mutuallyExclusiveOptionsPassed[@]: -1} != '--makePresenceSheet'  &&  $2 =~ $regExNotPresenceSheet ]] ||
                     [[ ${mutuallyExclusiveOptionsPassed[@]: -1}  = '--makePresenceSheet'  &&  $2 =~ $regExPresenceSheet ]]; then
                    EXHND_exercisesFromPoolAsNumbers="$2"
                    shift 2
                else
                    PrintError "The value of the option \"$1\" was not correctly specified!"; exit -1
                fi
                ;;
            --sheetSubtitlePostfix )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                if [ "$2" != '' ] && [[ ! $2 =~ ^- ]]; then
                    EXHND_exerciseSheetSubtitlePostfix="$2"
                else
                    PrintError "The value of the option \"$1\" was not correctly specified!"; exit -1
                fi
                shift 2 ;;
            --showAlsoSolutions )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                EXHND_showAlsoSolutions="TRUE"
                shift ;;
            --ofExam )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                EXHND_solutionOfExam="TRUE"
                shift ;;
            --sheetNumber )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                if [ "$2" != '' ] && [[ ! $2 =~ ^- ]]; then
                    EXHND_sheetNumber="$2"
                else
                    PrintError "The value of the option \"$1\" was not correctly specified!"; exit -1
                fi
                shift 2 ;;
            --final )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                EXHND_isFinal='TRUE'
                shift ;;
            --fix )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                EXHND_isFinal='TRUE'
                EXHND_fixFinal='TRUE'
                shift ;;
            --showAllExercises )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                EXHND_displayAlreadyUsedExercises='TRUE'
                shift ;;
            --biWeeklySheet )
                __static__CheckSecondaryOption ${mutuallyExclusiveOptionsPassed[@]: -1} $1
                EXHND_isBiWeeklySheet='TRUE'
                shift ;;
            --doNotPrintWatermark )
                #This option is general and it is on purpose NOT in the help, since the user should not use it...
                EXHND_doNotPrintWatermark='TRUE'
                shift ;;
            *)
                PrintError "Unrecognized option \"$1\"!"; exit -1; shift ;;
        esac
    done

    if [ ${#mutuallyExclusiveOptionsPassed[@]} -gt 1 ]; then
        PrintError "Multiple mutually exclusive options were passed to the script! Use the \"--help\" option to check."
        exit -1
    fi
}

function FurtherChecksOnCommandLineOptions(){
    if [ ${EXHND_makeExerciseSheet} = 'TRUE' ] || [ ${EXHND_makeExam} = 'TRUE' ]; then
        if [ ${EXHND_isFinal} = 'TRUE' ] && [ ${EXHND_showAlsoSolutions} = 'TRUE' ]; then
            PrintError "Option \"--showAlsoSolutions\" cannot be combined with the option \"--final\"."; exit -1
        fi
    fi
}

#===============================================================================================================================#
#NOTE: The functions
#         __static__SplitCombinedShortOptionsInSingleOptions
#         __static__ReplaceShortOptionsWithLongOnes
#      will be used with readarray and therefore
#      the printf in the end uses '\n' as separator (this preserves spaces
#      in options)
function __static__SplitCombinedShortOptionsInSingleOptions(){
    local newOptions value option splittedOptions
    newOptions=()
    for value in "$@"; do
        if [[ $value =~ ^-[[:alpha:]]+$ ]]; then
            splittedOptions=( $(grep -o "." <<< "${value:1}") )
            for option in "${splittedOptions[@]}"; do
                newOptions+=( "-$option" )
            done
        else
            newOptions+=( "$value" )
        fi
    done
    printf "%s\n" "${newOptions[@]}"
}

function __static__KeyInArray(){
    local array key
    key=$1; array=$2
    if eval '[ ${'$array'[$key]+isSet} ]'; then
        return 0;
    else
        return 1;
    fi
}

function __static__ReplaceShortOptionsWithLongOnes(){
    local newOptions value
    newOptions=()
    for value in "$@"; do
        if [ "${value}" = '' ]; then # Function __static__KeyInArray cannot be called with empty value!
            newOptions+=( "${value}" )
            continue
        fi
        if __static__KeyInArray "${value}" mapOptions; then
            newOptions+=( ${mapOptions[$value]} )
        else
            newOptions+=( "${value}" )
        fi
    done
    printf "%s\n" "${newOptions[@]}"
}

function __static__PrintHelpHeader(){
    printf "\e[1;38;5;44m"
    printf "           ____ _  __ ____ ___   _____ ____ ____ ____      __ __ ___    _  __ ___   __    ____ ___    \n"
    printf "          / __/| |/_// __// _ \ / ___//  _// __// __/     / // // _ |  / |/ // _ \ / /   / __// _ \   \n"
    printf "         / _/ _>  < / _/ / , _// /__ _/ / _\ \ / _/      / _  // __ | /    // // // /__ / _/ / , _/   \n"
    printf "        /___//_/|_|/___//_/|_| \___//___//___//___/     /_//_//_/ |_|/_/|_//____//____//___//_/|_|    \n"
    printf "                                                                                                      \n"
    printf "\n\e[22m"
    printf "     This script is intended to structure the work associated to the tutorials of a lecture. For more \n"
    printf "     information about the general functionality refer to the README file. Here in the following you  \n"
    printf "     find a list of existing command line options together with a minimal explanation of each one.    \n"
    printf "\e[0m\n"
}

function __static__AddOptionToHelper(){
    local type option indentation widthOption
    #Here option could be the short option with something appended to distinguish between repeated secondary options.
    #For example, -e is used both for -P and for the rest. To print the correct description for -e used with -P
    #we pass to this function "-eP" as second argument and we use ${option:0:2} when we need only -e
    type="$1"; option="$2"
    indentation='    '; widthOption=28
    if [ "${type}" = 'PRIMARY' ]; then
        printf "\e[1;38;5;208m${indentation}"
    elif [ "${type}" = 'SECONDARY' ]; then
        printf "\e[38;5;228m${indentation}"
    else
        PrintInternal "Function \"${FUNCNAME[0]}\" called with unknown first argument (type of option)!"; exit -1
    fi
    printf "%-${widthOption}s%s" "${option:0:2} | ${mapOptions[${option:0:2}]}" "  ->  "
    printf "${optionHelp[$option]//\\n/\\n$(printf "%${widthOption}s" '')      ${indentation}}\n\e[0m"
}

function __static__PrintHelpFooter(){
    printf "\n\e[38;5;14m  \e[1m\e[4mNOTES\e[24m:\e[22m"
    printf " 1) The \e[1;38;5;208morange\e[22;38;5;14m options are mutually exclusive!\n"
    printf "         2) The \e[1;38;5;228mcream\e[22;38;5;14m options are secondary to the primary previously specified.\n"
    printf "         3) Values of the options have to be specified after the option leaving a space (no = sign is accepted).\n"
    printf "         4) Short options can be combined, e.g. \e[38;5;177m-Efn 3\e[38;5;14m is equivalent to \e[38;5;177m-E -f -n 3\e[38;5;14m."
    printf "\e[0m\n\n\n"
}

function __static__PrintHelp(){
    declare -rA optionHelp=(['-U']='Set up of the evironment creating local definitions template and folders.'
                            ['-N']='Create a new empty exercise and a new empty solution, which are added to the pools.\n\e[22mThe name of the exercise may be specified as argument, but it cannot start with \"-\".'
                            ['-E']='Create a new exercise sheet or fix a previous one.'
                            ['-S']='Create a new solution sheet or fix a previous one.'
                            ['-P']='Create a new presence sheet. \e[22mA students file to be used may be specified as argument, \nbut it cannot start with \"-\". This file is supposed to be in the "'"$(basename ${EXHND_presenceSheetFolder})"'" folder.'
                            ['-X']='Create a new exam or fix a previous one.'
                            ['-L']='Get list of exercise tex files used in already produced final exercises.'
                            ['-T']='Create a tarball with all final pdf files as well as a ready-to-be-inherited archive.\n\e[22mA prefix for the tarball names (not starting with \"-\") may be specified as argument.'
                            ['-I']='Use the tarball specified as value to setup the evironment based on previous work.\n\e[22mThis option must be used from an empty folder and the specified tarball should\nhave been produced with the -T option and it has to end with "'"${EXHND_tarballExerciseHandlerPostfix}"'".'
                            ['-V']='Print the version in use of the Exercise Handler.'
                            ['-a']='Display all available exercise to let the user choose.\nBy default, only those still not used for final sheets are listed.'
                            ['-e']='Avoid interactive selection of exercises and choose them directly.\nUse a comma separated list, where ranges X-Y are allowed (boundaries included).\nOrder is respected, e.g. \"7,3-1,9\" is expanded to [7 3 2 1 9].'
                            ['-eP']='Specify the headers of the exercise columns. Use a comma separated\nlist, where sub-exercises X.Y are allowed (e.g. \"1,2.1,2.2,3\").'
                            ['-eS']='Show also exercises in the solution sheet.'
                            ['-p']='Set the exercise sheet subtitle postfix.'
                            ['-pP']='Set the presence sheet full subtitle (present date if not given).'
                            ['-s']='Show solutions of exercises in the same file.'
                            ['-m']='Make solution of exam instead of exercise sheet.'
                            ['-n']='Set the number of the sheet to be produced.'
                            ['-nP']='Set the presence sheet number.'
                            ['-f']='Move the produced pdf and auxiliary files to the corresponding final folder.'
                            ['-x']='Produce again a final sheet using its exercises and overwriting it.\nIt implies -f. Use -n to specify the exercise sheet number.'
                            ['-b']='Consider the exercise sheet valid for two weeks and divide then the signature column.' )
    local primaryOption secondaryOption
    __static__PrintHelpHeader
    for primaryOption in ${primaryOptions[@]}; do
        __static__AddOptionToHelper 'PRIMARY' ${primaryOption}
        for secondaryOption in ${secondaryToPrimaryOptionsMapping[${primaryOption}]}; do #on purpose not quoted to split secondary options
            if [ $primaryOption = '-P' ] && [[ $secondaryOption =~ ^-[epn]$ ]] ; then
                secondaryOption+='P'
            elif [ $primaryOption = '-S' ] && [[ $secondaryOption =~ ^-[e]$ ]] ; then
                secondaryOption+='S'
            fi
            __static__AddOptionToHelper 'SECONDARY' ${secondaryOption}
        done
        echo
    done
    __static__PrintHelpFooter
}

function __static__GetKeyFromValueInArray(){
    local value key array content
    value=$1; array=$2;
    for key in $(eval echo "\${!${array}[@]}"); do
        if [ $(eval echo "\${${array}[$key]}") = $value ]; then
            printf "%s" "$key"
            return 0
        fi
    done
    return 1
}

function __static__CheckSecondaryOption(){
    if [ ${#mutuallyExclusiveOptionsPassed[@]} -eq 0 ]; then
        PrintError "Secondary options were specified without any primary one!"; exit -1
    fi
    local primaryOption secondaryOption
    primaryOption=$(__static__GetKeyFromValueInArray $1 mapOptions) || exit -1
    secondaryOption=$(__static__GetKeyFromValueInArray $2 mapOptions) || exit -1
    if [ $(grep -c -- "${secondaryOption}" <<< "${secondaryToPrimaryOptionsMapping[$primaryOption]}") -eq 0 ]; then
        PrintError "The specified option \"${secondaryOption}\" is not a secondary option of \"${primaryOption}\"!"; exit -1
    fi
}
