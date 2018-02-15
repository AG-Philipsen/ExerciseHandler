function __static__CreateTexLocaldefsTemplate(){
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
          ${EXHND_finalExamSheetFolder}\
          ${EXHND_figuresFolder}\
          ${EXHND_temporaryFolder}
    if [ ! -f ${EXHND_texLocaldefsFilename} ]; then
        __static__CreateTexLocaldefsTemplate
        PrintInfo "An empty template for the local definitions file \"$(basename ${EXHND_texLocaldefsFilename})\" to be filled out has been created."
    fi
}
