function __static__CreateTexLocaldefsTemplate(){
    #Template production, overwriting the file
    rm -f ${EXHND_texLocaldefsFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_texLocaldefsFilename}
    echo '%__BEGIN_OPTIONS__%'
    echo '\PassOptionsToPackage{english}{babel} %Use similar lines if needed'
    echo -e '%__END_OPTIONS__%\n\n\n'
    echo '%__BEGIN_PACKAGES__%'
    echo '\usepackage{arrayjobx}'
    echo '%\usepackage{graphicx} %Uncomment this line if your exercises need figures'
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
    echo '\newcommand{\examDuration}{}'
    echo '\newcommand{\examDate}{}'
    echo '\newcommand{\examRules}{}'
    echo '\newcommand{\makeBinaryExam}{false}                     %Set it to true if needed'
    echo '\newcommand{\myEveryEvenRowColor}{gray}'
    echo '\newcommand{\hideSignatureColumnInPresenceSheet}{false} %Set it to true if needed'
    echo '\newcommand{\hideExercisesColumnInPresenceSheet}{false} %Set it to true if needed'
    echo -e '%__END_DEFINITIONS__%\n\n\n'
    echo -e '%__BEGIN_BODY__%\n%__END_BODY__%\n\n\n'
    #Restore standard output
    exec 1>&3
}

function __static__ChooseThemeToBeUsed(){
    local availableThemes theme
    availableThemes=( $(find ${EXHND_themesDirectory} -maxdepth 1 -name "*Theme.tex") )
    if [ ${#availableThemes[@]} -gt 1 ]; then
        PS3="$(printf "\n\e[38;5;14mChoose the theme to be using by the Exercise Handler: \e[38;5;219m")"
        printf "\e[38;5;14mCheck out at https://github.com/AG-Philipsen/ExerciseHandler how the availables themes look like!\n\n\e[38;5;219m"
        select theme in ${availableThemes[@]##*/}; do
            if [[ ${REPLY} =~ ^[1-9][0-9]*$ ]] && [ ${REPLY} -le ${#availableThemes[@]} ]; then
                printf "\n\e[0m"
                EXHND_themeToBeUsed="${EXHND_themesDirectory}/${theme}"
                return
            fi
        done
    else
        if [ "${availableThemes[0]}" != "${EXHND_defaultTheme}" ]; then
            PrintInternal "Default theme not found."
            exit -1
        else
            EXHND_themeToBeUsed=${EXHND_defaultTheme}
        fi
    fi
}


function MakeSetup(){
    mkdir -p\
          ${EXHND_exercisePoolFolder}\
          ${EXHND_solutionPoolFolder}\
          ${EXHND_finalExerciseSheetFolder}\
          ${EXHND_finalSolutionSheetFolder}\
          ${EXHND_finalExamSheetFolder}\
          ${EXHND_presenceSheetFolder}\
          ${EXHND_figuresFolder}\
          ${EXHND_temporaryFolder}
    touch ${EXHND_listOfStudentsFilename}
    if [ ! -f ${EXHND_texLocaldefsFilename} ]; then
        __static__CreateTexLocaldefsTemplate
        PrintInfo "An empty template for the local definitions file \"$(basename ${EXHND_texLocaldefsFilename})\" to be filled out has been created."
    fi
    if [ -f ${EXHND_themeFilename} ]; then
        PrintInfo "Found existing theme, leaving it untouched."
    else
        __static__ChooseThemeToBeUsed
        if [ -f "${EXHND_themeToBeUsed}" ]; then
            cp "${EXHND_themeToBeUsed}" ${EXHND_themeFilename}
            PrintInfo "Theme \"$(basename ${EXHND_themeToBeUsed})\" copied to invoking directory as \"$(basename ${EXHND_themeFilename})\"."
        else
            PrintInternal "Theme to be used not found."
        fi
    fi
}
