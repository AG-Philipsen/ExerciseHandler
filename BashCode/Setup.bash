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
    echo '\newcommand{\makeBinaryExam}{false}                     %Set it to true is needed'
    echo '\newcommand{\myEveryEvenRowColor}{gray}'
    echo '\newcommand{\hideSignatureColumnInPresenceSheet}{false} %Set it to true is needed'
    echo '\newcommand{\hideExercisesColumnInPresenceSheet}{false} %Set it to true is needed'
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
        mv "${EXHND_themeFilename}" "${EXHND_temporaryFolder}/$(basename ${EXHND_themeFilename})_$(date +%d.%m.%Y_%H%M%S)"
        PrintInfo "Existing theme moved to temporary folder \"$(basename ${EXHND_temporaryFolder})\"."
    fi
    if [ "${EXHND_userDefinedTheme}" != '' ]; then
        if [ ! -f "${EXHND_userDefinedTheme}" ]; then
            PrintError "Provided theme file \"${EXHND_userDefinedTheme}\" not found." "Please, provide an existing (global) file name and run again the setup."
            exit -1
        else
            cp "${EXHND_userDefinedTheme}" ${EXHND_themeFilename}
            PrintInfo "User provided theme copied to invoking directory."
        fi
    else
        cp ${EXHND_defaultTheme} ${EXHND_themeFilename}
        PrintInfo "Default theme copied to invoking directory."
    fi
}
