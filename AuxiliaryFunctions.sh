function PrintWarning(){
    printf "\e[38;5;11m \e[1m\e[4mWARNING\e[24m:\e[21m %s\e[0m\n\n" "$1"
}

function PrintError(){
    printf "\e[38;5;9m \e[1m\e[4mERROR\e[24m:\e[21m %s\e[0m\n\n" "$1"
}

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
                printf "    -s | --setup                     ->    Set up of the evironment creating local definitions template and folders.\n"
                printf "    -n | --newExercise               ->    Create a new empty exercise, which is added to the pool of exercises. \n"
                printf "\e[21;38;5;2m\n"
                printf "    -p | --exerciseSheetPostfix      ->    Set the exercise sheet subtitle postfix. \n"
                printf "    -N | --sheetNumber               ->    Set the sheet number to appear in the exercise sheet title. \n"

                printf "    -t | --themeFile                 ->    default value = ClassicTheme \n"
                printf "                                           The user can provide a custom theme file.\n"
                printf "    -f | --final                     ->    Move the produced files ( .tex .pdf and possibly figures) to the tutorial folder. \n"
                printf "                                           in the subfolder corresponding to the sheet number.\n"
                printf "                                           \e[1;32mThe sheet number is automatically set unless specified via the -N option. \e[0;32m \n"
                printf "\n\n\e[38;5;14m  \e[1m\e[4mNOTE\e[24m:\e[21m"
                printf " The \e[1;38;5;4mblue\e[21;38;5;14m options are mutually exclusive!"
                printf "\e[0m\n\n\n"
                exit 0
                shift ;;
            -s | --setup )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_doSetup="TRUE"
                shift;;
            -n | --newExercise )
                mutuallyExclusiveOptionsPassed+=( $1 )
                EXHND_produceNewExercise='TRUE'
                shift ;;
            -p | --exerciseSheetPostfix )
                EXHND_exerciseSheetSubtitlePostfix="$2"
                shift 2 ;;
            -N | --sheetNumber )
                EXHND_exerciseSheetNumber="$2"
                shift 2 ;;

            -t | --themeFile )
                printf "\e[38;5;9m\n Option \e[1m$1\e[21m! still to be implemented! Aborting...\n\n\e[0m"; exit -1; shift ;;
            -f | --final )
                printf "\e[38;5;9m\n Option \e[1m$1\e[21m! still to be implemented! Aborting...\n\n\e[0m"; exit -1; shift ;;
            *)
                printf "\e[38;5;9m\n Unrecognized option \e[1m$1\e[21m! Aborting...\n\n\e[0m"; exit -1; shift ;;
        esac
    done

    if [ ${#mutuallyExclusiveOptionsPassed[@]} -gt 1 ]; then
        PrintError "Multiple mutually exclusive options were passed to the script! Use the \"--help\" option to check. Aborting..."
        exit -1
    fi
}

function DetermineSheetNumber(){
    echo '1'
}

function CreateTexLocaldefsTemplate(){
    #Template production, overwriting the file
    rm -f ${EXHND_texLocaldefsFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_texLocaldefsFilename}
    echo '%__BEGIN_PACKAGES__%'
    echo '\usepackage{arrayjob}'
    echo -e '%__END_PACKAGES__%\n\n\n'
    echo '%__BEGIN_DEFINITIONS__%'
    echo '\def\lecture{}      '
    echo '\def\professor{}    '
    echo '\def\semester{}     '
    echo '\newarray\Tutor     '
    echo '\newarray\TutorMail '
    echo '\Tutor(1)={}        '
    echo '\TutorMail(1)={}    '
    echo '%\Tutor(2)={}       '
    echo '%\TutorMail(2)={}   '
    echo '%\Tutor(3)={}       '
    echo '%\TutorMail(3)={}   '
    echo '\def\exerciseSheetSubtitlePrefix{}'
    echo -e '%__END_DEFINITIONS__%\n\n\n'
    echo -e '%__BEGIN_BODY__%\n%__END_BODY__%\n\n\n'
    #Restore standard output
    exec 1>&3
}

function MakeSetup(){
    mkdir -p\
          ${EXHND_exercisePoolFolder}\
          ${EXHND_solutionPoolFolder}\
          ${EXHND_finalExerciseSheetFolder}\
          ${EXHND_finalSolutionSheetFolder}\
          ${EXHND_temporaryFolder}
    if [ ! -f ${EXHND_texLocaldefsFilename} ]; then
        CreateTexLocaldefsTemplate
    fi
}

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
            break
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


function CheckBlocksInFile(){
    local filename blocksName block
    filename="$1"; shift
    blocksName=( $@ )
    for block in "${blocksName[@]}"; do
        if [ $(grep -c "^[[:blank:]]*%__BEGIN_${block}__%[[:blank:]]*$" ${filename}) -ne 1 ] || [ $(grep -c "^[[:blank:]]*%__END_${block}__%[[:blank:]]*$" ${filename}) -ne 1 ]; then
            PrintError "Block %__BEGIN_${block}__%  ->  %__END_${block}__% not correctly found in \"${filename}\" file! Aborting..."; exit -2
        fi
    done
}

function CheckTexLocaldefsTemplate(){
    local line brackets oldIFS
    #Parse file line by line
    while read -r line || [[ -n "${line}" ]]; do # [[ -n "${line}" ]] is to read also last line if it does not end with \n
        if [[ $line =~ ^[[:space:]]*% ]]; then
            continue
        fi
        if [[ $line =~ \\def\\exerciseSheetSubtitlePrefix\{\} ]]; then # to skip optional fields in the check
            continue
        fi
        oldIFS=${IFS}
        IFS=$'\n'
        for brackets in $(grep -o "{[^{}]*}" <<< "${line}"); do
            if [ "$brackets" = '{}' ]; then
                PrintWarning "Found empty field(s) in \"${EXHND_texLocaldefsFilename}\"! Final result could be affected!"
                break 2
            fi
        done
        IFS=${oldIFS}
    done < "${EXHND_texLocaldefsFilename}"
    #General checks on blocks
    CheckBlocksInFile "${EXHND_texLocaldefsFilename}" "PACKAGES" "DEFINITIONS" "BODY"
}

function LookForExercisesAndMakeList(){
    if [ ! -d ${EXHND_exercisePoolFolder} ]; then
        PrintError "No exercise pool folder \"${EXHND_exercisePoolFolder}\" has been found! Aborting..."; exit -2
    fi
    EXHND_exerciseList=( $(ls ${EXHND_exercisePoolFolder}/*.tex 2> /dev/null | xargs -d '\n' -n 1 basename) )
    if [ ${#EXHND_exerciseList[@]} -eq 0 ]; then
        PrintError "No exercise .tex file has been found in pool folder \"${EXHND_exercisePoolFolder}\"! Aborting..."; exit -2
    fi
}

function PrintListOfExercises(){
    local givenList index numberOfTerminalColumns longestFilenameLength\
          tableColumnsWidth maxNumberOfColumnsInTable stringFormat
    printf "\e[1;38;5;207m\n List of exercises found in the pool\e[21m:\n\n\e[0m"
    givenList=( $@ )
    index=0
    for index in "${!givenList[@]}" ; do
        givenList[${index}]="$(printf "%3d" $((index+1)))) ${givenList[${index}]}"
    done
    numberOfTerminalColumns=$(tput cols)
    longestFilenameLength=$(printf "%s\n" "${givenList[@]}" | awk '{print length}' | sort -n | tail -n1)
    tableColumnsWidth=$((longestFilenameLength+10))
    maxNumberOfColumnsInTable=$((numberOfTerminalColumns/tableColumnsWidth))
    stringFormat=""; for((index=0; index<maxNumberOfColumnsInTable; index++)); do stringFormat+="%-${tableColumnsWidth}s"; done
    printf "${stringFormat}\n" "${givenList[@]}"

    #TODO: Print list going vertically and not horizontally!
}

function PickupExercises(){
    printf "\e[38;5;207m\n Please, insert the exercise numbers that you wish to include in the exercise sheet (sperated by space): \e[0m\e[s"
    local selectedExercises index givenList
    givenList=( $@ )
    while read -a selectedExercises; do
        [ ${#selectedExercises[@]} -eq 0 ] && printf "\e[u\e[1A" && continue
        for index in ${selectedExercises[@]}; do
            if [[ ${index} =~ ^[1-9][0-9]*$ ]] && [ ${index} -le ${#givenList[@]} ]; then
                continue
            else
                printf "\n\e[1;38;5;208m Invalid input!\e[21m\e[38;5;207m Please, insert the \e[1mexercise numbers sperated by space\e[21m: \e[0m\e[s"
                continue 2
            fi
        done
        break
    done
    for index in ${selectedExercises[@]}; do
        EXHND_choosenExercises+=( ${givenList[$((index-1))]} )
    done
    echo
}

function CheckChoosenExercises(){
    local exercise
    for exercise in ${EXHND_choosenExercises[@]}; do
        CheckBlocksInFile ${EXHND_exercisePoolFolder}/${exercise}  "PACKAGES" "DEFINITIONS" "BODY"
    done
}


#=========================================================================================================================================================#

function ExtractBlockFromFileAndAppendToAnotherFile(){
    local inputFilename outputFilename partOfDocument
    inputFilename="$1"
    outputFilename="$2"
    partOfDocument="$3"
    awk '/%__BEGIN_'${partOfDocument}'__%/,/%__END_'${partOfDocument}'__%/' ${inputFilename} | head -n -1 | tail -n +2 >> ${outputFilename}
}

function ProduceTexAuxiliaryFile(){
    local outputFilename partOfDocument exercise
    outputFilename="$1"
    partOfDocument="$2"
    if [ ${partOfDocument} = 'PACKAGES' ]; then
        ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_repositoryDirectory}/${EXHND_themeFilename}  ${outputFilename}  ${partOfDocument}
    fi
    ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_texLocaldefsFilename}  ${outputFilename}  ${partOfDocument}
    for exercise in ${EXHND_choosenExercises[@]}; do
        ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_exercisePoolFolder}/${exercise}  ${outputFilename}  ${partOfDocument}
    done
    #NOTE: We decided to use guards to divide the parts of the exercises file, because the parsing is then easier.
    #      For example, to extract packages one could do something like,
    #         awk '{split($0, res, "%"); if(res[1] !~ /^[ ]*$/){print res[1]}}' file.tex | sed 's/^[[:blank:]]*//g' | tr '\n' ' ' | grep -Eo '\\usepackage(\[[^]]*\])?{[^}]+}'
    #      but there are many cases that could break this down.
}

function CheckTexPackagesFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}

function CheckTexDefinitionsFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}


function ProduceTexMainFile(){
    local mainTexFilename
    mainTexFilename="$1"
    rm -f ${mainTexFilename}
    #Redirect standard output to file
    exec 3>&1 1>${mainTexFilename}
    #Template production, overwriting the file
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo ''
    echo "\input{$EXHND_repositoryDirectory/${EXHND_themeFilename%.tex}}"
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet[${EXHND_exerciseSheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}
