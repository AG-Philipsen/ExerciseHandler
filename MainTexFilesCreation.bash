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
    echo "  \Sheet[Solution of exercise][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]" #subtitle passed to give freedom in customized theme!
    echo '  %Exercises'
    echo '  \input{Document}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

function ProduceExamTexMainFile(){
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
