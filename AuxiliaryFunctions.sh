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
                printf "    -e | --exercisesFromPool         ->    Avoid interactive selection of exercises and choose them directly. \n"
                printf "                                           Use a comma separated list, where ranges X-Y are allowed (boundaries included).\n"
                printf "                                           Order is respected, e.g. \"7,3-1,9\" is expanded to [7 3 2 1 9].\n"
                printf "    -p | --exerciseSheetPostfix      ->    Set the exercise sheet subtitle postfix. \n"
                printf "    -N | --sheetNumber               ->    Set the sheet number to appear in the exercise sheet title. \n"
                printf "    -f | --final                     ->    Move the produced pdf file to the corresponding final folder. \n"
                printf "    -a | --showAllExercises          ->    Display all available exercise to let the user choose. \n"
                printf "                                           By default, only those still not used for final sheets are listed.\n"

                printf "    -t | --themeFile                 ->    default value = ClassicTheme \n"
                printf "                                           The user can provide a custom theme file.\n"
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
            -N | --sheetNumber )
                EXHND_exerciseSheetNumber="$2"
                shift 2 ;;
            -f | --final )
                EXHND_isFinal='TRUE'
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

function IsInvokingPositionWrong(){
    local listOfFiles listOfFolders filename foldername
    listOfFiles=( ${EXHND_texLocaldefsFilename} )
    listOfFolders=( ${EXHND_exercisePoolFolder}
                    ${EXHND_solutionPoolFolder}
                    ${EXHND_finalExerciseSheetFolder}
                    ${EXHND_finalSolutionSheetFolder}
                    ${EXHND_figuresFolder}
                    ${EXHND_temporaryFolder} )
    for filename in "${listOfFiles[@]}"; do
        if [ ! -f "${filename}" ]; then
            return 0
        fi
    done
    for foldername in "${listOfFolders[@]}"; do
        if [ ! -d "${foldername}" ]; then
            return 0
        fi
    done
    return 1
}

function DetermineSheetNumber(){
    local lastSheetNumber;
    lastSheetNumber=$(ls "${EXHND_finalExerciseSheetFolder}" | tail -n1 | grep -o "[0-9]\+" | sed 's/^0*//')
    if [[ $lastSheetNumber =~ ^[0-9]*$ ]]; then
        echo $((lastSheetNumber+1))
    else
        echo '1'
    fi
}

function CreateTexLocaldefsTemplate(){
    #Template production, overwriting the file
    rm -f ${EXHND_texLocaldefsFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_texLocaldefsFilename}
    echo '%__BEGIN_PACKAGES__%'
    echo '\usepackage{arrayjobx}'
    echo '%\usepackage{graphicx} %Uncomment this line if your exercises needs figures'
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
          ${EXHND_figuresFolder}\
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
    if [ ${EXHND_displayAlreadyUsedExercises} = 'FALSE' ]; then
        if [ -f ${EXHND_exercisesLogFilename} ]; then
            local usedExercises exerciseOfList index
            usedExercises=( $(awk '{print $2}' ${EXHND_exercisesLogFilename}) )
            for exerciseOfUsed in ${usedExercises[@]}; do
                for index in ${!EXHND_exerciseList[@]}; do
                    if [ ${EXHND_exerciseList[$index]} = ${exerciseOfUsed} ]; then
                        unset -v 'EXHND_exerciseList[$index]'
                        continue 2
                    fi
                done
            done
        fi
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

function GetArrayFromCommaSeparatedListOfIntegersAcceptingRanges(){
    local string
    string="$1"
    awk 'BEGIN{RS=","}/\-/{split($0, res, "-"); if(res[1]<=res[2]){for(i=res[1]; i<=res[2]; i++){printf "%d\n", i}}else{for(i=res[1]; i>=res[2]; i--){printf "%d\n", i}}; next}{printf "%d\n", $0}' <<< "${string}"
}

function FillChoosenExercisesArray(){
    local index pool numbersOfChosenExercises
    numbersOfChosenExercises=( $1 )
    pool=( $2 )
    for index in ${numbersOfChosenExercises[@]}; do
        EXHND_choosenExercises+=( ${pool[$((index-1))]} )
    done
}

function IsAnyExerciseNotExisting(){
    local index maximum numbersOfChosenExercises
    maximum=$1; shift; numbersOfChosenExercises=( $@ )
    for index in ${numbersOfChosenExercises[@]}; do
        if [ ${index} -gt ${maximum} ]; then
            return 0
        fi
    done
    return 1
}

function PickupExercises(){
    printf "\e[38;5;14m\n Please, insert the exercise numbers that you wish to include in the exercise sheet.\n"
    printf " Use a comma separated list WITHOUT SPACES; ranges X-Y are allowed (boundaries included)\n"
    printf " and order is respected, e.g. \"7,3-1,9\" is expanded to [7 3 2 1 9]: \e[0m\e[s"
    local selectedExercises index givenList oldIFS
    givenList=( $@ )
    while read selectedExercises; do #Here selectedExercises is a variable
        [ "${selectedExercises}" = '' ] && printf "\e[u\e[1A" && continue
        if [[ ! ${selectedExercises} =~ ^[1-9][0-9]*([,\-][1-9][0-9]*)*$ ]]; then
            printf "\n\e[1;38;5;208m Invalid input!\e[21m\e[38;5;14m Please, insert the exercise numbers: \e[0m\e[s"; continue
        fi
        selectedExercises=( $(GetArrayFromCommaSeparatedListOfIntegersAcceptingRanges ${selectedExercises}) ) #Here selectedExercises becomes an array!
        if IsAnyExerciseNotExisting ${#givenList[@]} ${selectedExercises[@]}; then
            printf "\n\e[1;38;5;208m Not existent exercise inserted!\e[21m\e[38;5;14m Please, insert the exercise numbers: \e[0m\e[s"; continue 2
        fi
        break
    done
    FillChoosenExercisesArray "${selectedExercises[*]}" "${givenList[*]}" #https://stackoverflow.com/a/16628100
    echo
}

function CheckChoosenExercises(){
    local exercise
    for exercise in ${EXHND_choosenExercises[@]}; do
        CheckBlocksInFile ${EXHND_exercisePoolFolder}/${exercise}  "PACKAGES" "DEFINITIONS" "BODY"
    done
}


#=========================================================================================================================================================#

function CreateTemporaryCompilationFolder(){
    [ -d "${EXHND_compilationFolder}" ] && mv "${EXHND_compilationFolder}" "${EXHND_compilationFolder}_$(date +%d.%m.%Y_%H%M%S)"
    mkdir "${EXHND_compilationFolder}" 2>/dev/null || { PrintError "Cannot create \"${EXHND_compilationFolder}\"! Aborting..." && exit -2; }
}

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
        ExtractBlockFromFileAndAppendToAnotherFile  ${EXHND_themeFilename}  ${outputFilename}  ${partOfDocument}
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

function ProduceTexAuxiliaryFiles(){
    ProduceTexAuxiliaryFile ${EXHND_packagesFilename}    "PACKAGES"
    ProduceTexAuxiliaryFile ${EXHND_definitionsFilename} "DEFINITIONS"
    ProduceTexAuxiliaryFile ${EXHND_bodyFilename}        "BODY"
}

function CheckTexPackagesFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}

function CheckTexDefinitionsFile(){
    PrintWarning "Function \"${FUNCNAME}\" not implemented yet! It is up to you to avoid conflicts in loading packages!!"
}


function ProduceTexMainFile(){
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo ''
    echo '\input{Definitions}'
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo "\input{${EXHND_themeFilename%.tex}}"
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

function MakeCompilationInTemporaryFolder(){
    local index
    cd ${EXHND_compilationFolder}
    for index in {1..2}; do
        pdflatex -interaction=batchmode ${EXHND_mainFilename} >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            PrintError "Error occurred in pdflatex compilation!! Files can be found in \"${EXHND_compilationFolder}\" directory to investigate!"
            exit 0
        fi
    done
}

function MovePdfFileToTemporaryFolderOpenItAndRemoveCompilationFolder(){
    local newPdfFilename
    newPdfFilename="${EXHND_temporaryFolder}/$(basename ${EXHND_mainFilename%.tex})_$(date +%d.%m.%Y_%H%M%S).pdf"
    cp "${EXHND_mainFilename/.tex/.pdf}" "${newPdfFilename}" || exit -2
    xdg-open "${newPdfFilename}" >/dev/null 2>&1 &
    rm -r "${EXHND_compilationFolder}"
}

function MoveExerciseSheetFilesToFinalFolderOpenItAndRemoveCompilationFolder(){
    local newExerciseFilename destinationFolder texFile
    newExerciseFilename="$(basename ${EXHND_mainFilename%.tex})_$(printf "%02d" ${EXHND_exerciseSheetNumber})"
    destinationFolder="${EXHND_finalExerciseSheetFolder}/${newExerciseFilename}"
    if [ -d "${destinationFolder}" ]; then
        PrintError "Folder \"$(basename ${destinationFolder})\" for final sheet is already existing! Aborting..."; exit -2
    else
        mkdir "${destinationFolder}" || exit -2
    fi
    #Rename .tex file so that then I can move to final folder all .tex files from compilation folder
    mv "${EXHND_mainFilename}"  "${EXHND_mainFilename%/*}/${newExerciseFilename}.tex" || exit -2
    for texFile in ${EXHND_compilationFolder}/*.tex; do
        mv "${texFile}" "${destinationFolder}"
    done
    cp "${EXHND_mainFilename/.tex/.pdf}" "${destinationFolder}/${newExerciseFilename}.pdf" || exit -2
    xdg-open "${destinationFolder}/${newExerciseFilename}.pdf" >/dev/null 2>&1 &
    rm -r "${EXHND_compilationFolder}"
}

function UpdateExerciseLogfile(){
    local exercise
    touch ${EXHND_exercisesLogFilename}
    for exercise in ${EXHND_choosenExercises[@]}; do
        printf "%2d    %s\n" ${EXHND_exerciseSheetNumber} ${exercise} >> ${EXHND_exercisesLogFilename}
    done
}
