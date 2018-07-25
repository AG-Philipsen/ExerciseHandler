function PrintCodeVersion(){
    local gitTagShort gitTagLong tagDate
    gitTagLong=$(git -C "${EXHND_repositoryDirectory}" describe --tags 2>/dev/null)
    if [ $? -ne 0 ]; then
        PrintError "It was not possible to obtain the version in use!"\
                   "This probably (but not necessarily) means that you are"\
                   "behind any release in the Exercise Handler history."
        return
    fi
    gitTagShort=$(git -C "${EXHND_repositoryDirectory}" describe --tags --abbr=0 2>/dev/null)
    if [ $? -ne 0 ]; then
        PrintInternal "Unexpected error in \"${FUNCNAME}\" trying to obtain the closest git tag."; exit -1
    fi
    tagDate=$(date -d "$(git -C "${EXHND_repositoryDirectory}" tag -l "${gitTagShort}" --format='%(creatordate:short)')" +'%d %B %Y')
    if [ "${gitTagShort}" != "${gitTagLong}" ]; then
        PrintWarning "You are not using an official release of the Exercise Handler."\
                     "Unless you have a reason not to do so, it would be better"\
                     "to checkout a stable release. The last stable release behind"\
                     "the commit you are using is \"${gitTagShort}\" (${tagDate})."
    else
        PrintInfo "Exercise Handler, version ${gitTagShort} (${tagDate})"
    fi
}
