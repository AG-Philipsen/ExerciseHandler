function DefineGlobalVariables(){

    #Global internal variables
    readonly EXHND_vocabularyFilename="${EXHND_repositoryDirectory}/TexCode/Vocabulary.tex"
    readonly EXHND_defaultTheme="${EXHND_repositoryDirectory}/TexCode/Themes/ClassicTheme.tex"
    readonly EXHND_invokingDirectory="$(pwd)"
    readonly EXHND_themeFilename="${EXHND_invokingDirectory}/ThemeInUse.tex"
    readonly EXHND_texLocaldefsFilename="${EXHND_invokingDirectory}/TexLocaldefs.tex"
    readonly EXHND_exercisePoolFolder="${EXHND_invokingDirectory}/Exercises"
    readonly EXHND_solutionPoolFolder="${EXHND_invokingDirectory}/Solutions"
    readonly EXHND_finalExerciseSheetFolder="${EXHND_invokingDirectory}/FinalExerciseSheets"
    readonly EXHND_finalExerciseSheetPrefix="ExerciseSheet_"
    readonly EXHND_exercisesLogFilename=".exercises.log" #One in each final exercise sheet folder
    readonly EXHND_finalSolutionSheetFolder="${EXHND_invokingDirectory}/FinalSolutionSheets"
    readonly EXHND_finalSolutionSheetPrefix="SolutionSheet_"
    readonly EXHND_finalExamSheetFolder="${EXHND_invokingDirectory}/FinalExams"
    readonly EXHND_finalExamSheetPrefix="Exam_"
    readonly EXHND_finalExamSolutionPrefix="ExamSolution_"
    readonly EXHND_examLogFilename=".exam.log" #One in each final exam sheet folder
    readonly EXHND_presenceSheetFolder="${EXHND_invokingDirectory}/PresenceSheets"
    readonly EXHND_presenceSheetPrefix="PresenceSheet_"
    readonly EXHND_figuresFolder="${EXHND_invokingDirectory}/Figures"
    readonly EXHND_temporaryFolder="${EXHND_invokingDirectory}/tmp"
    readonly EXHND_temporaryPdfFilename="${EXHND_temporaryFolder}/LastPdfProduced.pdf"
    readonly EXHND_compilationFolder="${EXHND_temporaryFolder}/TemporaryCompilationFolder"
    readonly EXHND_optionsFilename="${EXHND_compilationFolder}/Options.tex"
    readonly EXHND_packagesFilename="${EXHND_compilationFolder}/Packages.tex"
    readonly EXHND_definitionsFilename="${EXHND_compilationFolder}/Definitions.tex"
    readonly EXHND_bodyFilename="${EXHND_compilationFolder}/Document.tex"
    readonly EXHND_mainFilename="${EXHND_compilationFolder}/MainFile.tex"
    EXHND_exerciseList=(); EXHND_choosenExercises=() #These arrays contain the basenames of the files
    EXHND_filesToBeUsedGlobalPath=() #This array contains the files for the final sheet
    EXHND_listOfStudentsFilename="${EXHND_presenceSheetFolder}/students"
    readonly EXHND_tarballExerciseHandlerPostfix='_ExerciseHandler.tar'
    readonly EXHND_tarballPdfPostfix='_pdfFiles.tar'

    #Variables with input from user
    EXHND_userDefinedTheme=''
    EXHND_newExerciseFilename=''
    EXHND_exerciseSheetSubtitlePostfix=''
    EXHND_sheetNumber=''
    EXHND_exercisesFromPoolAsNumbers=''
    EXHND_tarballPrefix="$(basename ${EXHND_invokingDirectory})"

    #Mutually exclusive options
    EXHND_doSetup='FALSE'
    EXHND_produceNewExercise='FALSE'
    EXHND_makeExerciseSheet='FALSE'
    EXHND_showAlsoSolutions='FALSE'
    EXHND_makeSolutionSheet='FALSE'
    EXHND_showAlsoExercises='FALSE'
    EXHND_solutionOfExam='FALSE'
    EXHND_makePresenceSheet='FALSE'
    EXHND_makeExam='FALSE'
    EXHND_listUsedExercises='FALSE'
    EXHND_printVersion='FALSE'
    EXHND_exportFilesAsTar='FALSE'

    #Behaviour options
    EXHND_isFinal='FALSE'
    EXHND_fixFinal='FALSE'
    EXHND_displayAlreadyUsedExercises='FALSE'
    EXHND_isBiWeeklySheet='FALSE'

}
