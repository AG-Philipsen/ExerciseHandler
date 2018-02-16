function ProduceExerciseTexMainFile(){
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
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet[][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceSolutionTexMainFile(){
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
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet[Solution of exercise sheet][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]" #subtitle passed to give freedom in customized theme!
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceExamTexMainFile(){
    if [ $(basename ${EXHND_themeFilename}) = 'ClassicTheme.tex' ] && [ ${#EXHND_choosenExercises[@]} -eq 1 ]; then
        PrintWarning "Having only one exercise in the exam leads to an extra empty line in cover page table -> https://tex.stackexchange.com/a/373213"
    fi
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\documentclass[a4paper]{article}'
    echo ''
    echo '\input{Packages}'
    echo '\usepackage{pgfplotstable, booktabs, colortbl, array}'
    echo ''
    echo '\input{Definitions}'
    echo '\graphicspath{{'"${EXHND_figuresFolder}/"'}}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading[false]'
    echo "  \Sheet[Exam][][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo "  \ExamCoverPage{${#EXHND_choosenExercises[@]}}"
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
