function ParseCommandLineParameters(){
    local mutuallyExclusiveOptionsPassed
    mutuallyExclusiveOptionsPassed=()
    while [ $# -gt 0 ]; do
        case $1 in
            -h | --help )
                printf "\e[1;38;5;44m\n"
                printf "              ____ _  __ ____ ___   _____ ____ ____ ____      __ __ ___    _  __ ___   __    ____ ___    \n"
                printf "             / __/| |/_// __// _ \ / ___//  _// __// __/     / // // _ |  / |/ // _ \ / /   / __// _ \   \n"
                printf "            / _/ _>  < / _/ / , _// /__ _/ / _\ \ / _/      / _  // __ | /    // // // /__ / _/ / , _/   \n"
                printf "           /___//_/|_|/___//_/|_| \___//___//___//___/     /_//_//_/ |_|/_/|_//____//____//___//_/|_|    \n"
                printf "                                                                                                         \n"
                printf "\n"
                printf "\e[21;38;5;4m\n"
                printf "    -U | --setup                     ->    Set up of the evironment creating local definitions template and folders.\n"
                printf "    -N | --newExercise               ->    Create a new empty exercise, which is added to the pool of exercises. \n"
                printf "    -E | --makeExerciseSheet         ->    Create a new exercise sheet or fix a previous one. \n"
                printf "    -S | --makeSolutionSheet         ->    Create a new solution sheet or fix a previous one. \n"
                printf "    -P | --makePresenceSheet         ->    Create a new presence sheet. \n"
                printf "    -X | --makeExam                  ->    Create a new exam or fix a previous one. \n"
                printf "    -L | --listUsedExercises         ->    Get list of exercise tex files used in already produced final exercises. \n"
                printf "\e[21;38;5;2m\n"
                printf "    -a | --showAllExercises          ->    Display all available exercise to let the user choose. \n"
                printf "                                           By default, only those still not used for final sheets are listed.\n"
                printf "    -e | --exercisesFromPool         ->    Avoid interactive selection of exercises and choose them directly. \n"
                printf "                                           Use a comma separated list, where ranges X-Y are allowed (boundaries included).\n"
                printf "                                           Order is respected, e.g. \"7,3-1,9\" is expanded to [7 3 2 1 9].\n"
                printf "    -p | --exerciseSheetPostfix      ->    Set the exercise sheet subtitle postfix. \n"
                printf "    -n | --sheetNumber               ->    Set the sheet number to appear in the exercise sheet title. \n"
                printf "    -f | --final                     ->    Move the produced pdf and auxiliary files to the corresponding final folder. \n"
                printf "    -x | --fix                       ->    Produce again a final sheet using its exercises and overwriting it. \n"
                printf "                                           It implies -f. Use -N to specify the exercise sheet number.\n"

                printf "    -t | --themeFile                 ->    default value = ClassicTheme \n"
                printf "                                           The user can provide a custom theme file.\n"
                printf "\n\n\e[38;5;14m  \e[1m\e[4mNOTE\e[24m:\e[21m"
                printf " The \e[1;38;5;4mblue\e[21;38;5;14m options are mutually exclusive!"
                printf "\e[0m\n\n\n"
                exit 0
                shift ;;
            -U | --setup )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_doSetup="TRUE"
                shift;;
            -N | --newExercise )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_produceNewExercise='TRUE'
                shift ;;
            -E | --makeExerciseSheet )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makeExerciseSheet='TRUE'
                shift ;;
            -S | --makeSolutionSheet )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makeSolutionSheet='TRUE'
                shift ;;
            -P | --makePresenceSheet )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makePresenceSheet='TRUE'
                shift ;;
            -X | --makeExam )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_makeExam='TRUE'
                shift ;;
            -L | --listUsedExercises )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_listUsedExercises='TRUE'
                shift ;;
            -e | --exercisesFromPool )
                if [[ $2 =~ ^[1-9][0-9]*([,\-][1-9][0-9]*)*$ ]]; then
                    EXHND_exercisesFromPoolAsNumbers="$2"
                else
                    printf "\e[38;5;9m The value of the option \e[1m$1\e[21m was not correctly specified!"; exit -1
                fi
                shift 2 ;;
            -p | --exerciseSheetPostfix )
                EXHND_exerciseSheetSubtitlePostfix="$2"
                shift 2 ;;
            -n | --sheetNumber )
                EXHND_exerciseSheetNumber="$2"
                shift 2 ;;
            -f | --final )
                EXHND_isFinal='TRUE'
                shift ;;
            -x | --fix )
                EXHND_isFinal='TRUE'
                EXHND_fixFinal='TRUE'
                shift ;;
            -a | --showAllExercises )
                EXHND_displayAlreadyUsedExercises='TRUE'
                shift ;;

            -t | --themeFile )
                PrintError "Option \"$1\" still to be implemented! Aborting..."; exit -1; shift ;;
            *)
                PrintError "Unrecognized option \"$1\"! Aborting..."; exit -1; shift ;;
        esac
    done

    if [ ${#mutuallyExclusiveOptionsPassed[@]} -gt 1 ]; then
        PrintError "Multiple mutually exclusive options were passed to the script! Use the \"--help\" option to check. Aborting..."
        exit -1
    fi
}
