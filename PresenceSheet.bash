function ProducePresenceSheet(){
    SetSheetNumber
    CheckTexLocaldefsTemplate
    CreateTemporaryCompilationFolder
    ProducePresenceSheetTexMainFile      $(__static__GetStudents) $(__static__GetNumberOfStudents $(__static__GetStudents)) $(__static__ParseExercisesString)
    MakeCompilationInTemporaryFolder
    MoveSheetFilesToFinalFolderOpenPdfAndRemoveCompilationFolder 'PRESENCE'
}

#=========================================================================================================================================================#

function __static__GetStudents(){
    echo "$(awk 'BEGIN {ORS=","}$0 ~ /^[[:space:]]*$/{next}{ print $0 }' $EXHND_listOfStudentsFilename)"
}

#=========================================================================================================================================================#

function __static__GetNumberOfStudents(){
    echo "$(grep -o ',' <<< "$1" | wc -l)"
}

#=========================================================================================================================================================#

function __static__ParseExercisesString(){
    if [[ $EXHND_exercisesFromPoolAsNumbers = "" ]]; then
        ReadOutExercisesFromFinalExerciseSheetLogFile
        echo "$(seq 1 ${#EXHND_choosenExercises[@]})"
    elif [[ $EXHND_exercisesFromPoolAsNumbers =~ ^[1-9][0-9]*([.][1-9][0-9]*)*([,][1-9][0-9]*([.][1-9][0-9]*)*)*$ ]]; then
        echo $EXHND_exercisesFromPoolAsNumbers | tr , "\n"
    else
        printf "\e[38;5;9m The value of the option \e[1m-n\e[21m was not correctly specified for the creation of the Presence sheet!\n"; exit -1
    fi
}

#=========================================================================================================================================================#

function ProducePresenceSheetTexMainFile(){
    local students="$1"
    local numberOfStudents="$2"
    shift 2
    local arrayOfExerciseNumbers=("$@")
    local exerciseString=$(echo $(printf ",Ex%s" ${arrayOfExerciseNumbers[@]}))
    rm -f ${EXHND_mainFilename}
    #Redirect standard output to file
    exec 3>&1 1>${EXHND_mainFilename}
    #Template production, overwriting the file
    echo '\documentclass[10pt,a4paper]{article}'
    echo '\usepackage{pgfplotstable,multirow,booktabs,colortbl,fullpage}'
    echo '\pgfplotsset{compat=1.13}'
    echo ''
    echo "\pgfmathsetmacro{\myNumberOfStudents}{$numberOfStudents + 2}"
    echo "\pgfmathsetmacro{\myNumberOfExercises}{${#arrayOfExerciseNumbers[@]}}"
    echo '\pgfmathsetmacro{\myColWidth}{5}'
    echo '\pgfmathsetmacro{\mySubColWidth}{\myColWidth / \myNumberOfExercises}'
    echo '\setlength{\tabcolsep}{0pt}'
    echo '\setlength{\aboverulesep}{0pt}'
    echo '\setlength{\belowrulesep}{0pt}'
    echo ''
    echo "\edef\colNames{No.,Name,Signature$exerciseString}"
    echo ''
    echo ''
    echo "\input{${EXHND_themeFilename%.tex}}"
    echo "\input{${EXHND_texLocaldefsFilename%.tex}}"
    echo ''
    echo '\ifthenelse{\boolean{switchOffSignatureColumn}}'
    echo "{\ifthenelse{\boolean{switchOffExerciseColumn}}{\edef\colNames{No.,Name}}{\edef\colNames{No.,Name$exerciseString}}}"
    echo "{\ifthenelse{\boolean{switchOffExerciseColumn}}{\edef\colNames{No.,Name,Signature}}{\edef\colNames{No.,Name,Signature$exerciseString}}}"
    echo '\ifthenelse{\boolean{switchOffSignatureColumn}}'
    echo '{\ifthenelse{\boolean{switchOffExerciseColumn}}{\def\headerString{\toprule & }}{\def\headerString{\toprule & & \multicolumn{\myNumberOfExercises}{C|}{\textsc{Exercises}}}}}'
    echo '{\ifthenelse{\boolean{switchOffExerciseColumn}}{\def\headerString{\toprule & & }}{\def\headerString{\toprule & & & \multicolumn{\myNumberOfExercises}{C|}{\textsc{Exercises}}}}}'
    echo ''
    echo '\newcolumntype{C}{>{\centering\arraybackslash}p{\myColWidth cm}}'
    echo '\newcolumntype{D}{>{\centering\arraybackslash}p{1cm}}'
    echo '\newcolumntype{E}{>{\centering\arraybackslash}p{\mySubColWidth cm}}'
    echo '\renewcommand{\arraystretch}{2}'
    echo '\pagestyle{empty}'
    echo ''
    echo '\begin{document}'
    echo '  \Heading'
    echo "  \Sheet[Presence][${EXHND_sheetNumber}][${EXHND_exerciseSheetSubtitlePostfix}]"
    echo '\begin{center}'
    echo '\pgfplotstableset{columns/No./.style={int detect,column type=|D|,column name=\textsc{N.}}}'
    echo '\pgfplotstableset{columns/Name/.style={string type,column type=C|,column name=\textsc{Name}}}'
    echo '\pgfplotstableset{columns/Signature/.style={string type,column type=C|,column name=\textsc{Signature}}}'
    echo ''
    for((i=0;i<${#arrayOfExerciseNumbers[@]}-1;i++)); do
        echo "\pgfplotstableset{columns/Ex${arrayOfExerciseNumbers[$i]}/.style={empty cells with={\raisebox{1.5pt}{\fbox{ \phantom{'}}}},int detect,column type=E,column name=\textsc{${arrayOfExerciseNumbers[$i]}}}}"
    done
    echo "\pgfplotstableset{columns/Ex${arrayOfExerciseNumbers[-1]}/.style={empty cells with={\raisebox{1.5pt}{\fbox{ \phantom{'}}}},int detect,column type=E|,column name=\textsc{${arrayOfExerciseNumbers[-1]}}}}"
    echo '\pgfplotstableset{create on use/No./.style={create col/set list={1,...,\myNumberOfStudents}}}'
    echo "\pgfplotstableset{create on use/Name/.style={create col/set list={${students}}}}"
    echo '\pgfplotstableset{create on use/Signature/.style={}}'
    for i in "${arrayOfExerciseNumbers[@]}"
    do
        echo "\pgfplotstableset{create on use/Ex${i}/.style={}}"
    done
    echo '\pgfplotstablenew[columns/.expand once={\colNames}]{\myNumberOfStudents}\loadedtable'
    echo '\pgfplotstabletypeset[columns/.expand once={\colNames},'
    echo 'every even row/.style={output empty row, before row={\myEveryEvenRowColor}},'
    echo "every head row/.style={before row=\headerString\\\,after row=\midrule},
                            every last row/.style={output empty row, after row=\bottomrule}
                                    ]\loadedtable"
    echo '\end{center}'
    echo '\end{document}'
    #Restore standard output
    exec 1>&3
}
