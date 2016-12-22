#!/bin/bash

#----------------------------------------------------------------------------------------#
#      ____ _  __ ____ ___   _____ ____ ____ ____      __  ___ ___    __ __ ____ ___     #
#     / __/| |/_// __// _ \ / ___//  _// __// __/     /  |/  // _ |  / //_// __// _ \    #
#    / _/ _>  < / _/ / , _// /__ _/ / _\ \ / _/      / /|_/ // __ | / ,<  / _/ / , _/    #
#   /___//_/|_|/___//_/|_| \___//___//___//___/     /_/  /_//_/ |_|/_/|_|/___//_/|_|     #
#                                                                                        #   
#----------------------------------------------------------------------------------------#
#                                                                                        #
#       Copyright (c) 2016 Alessandro Sciarra: sciarra@th.physik.uni-frankfurt.de        #
#                            Francesca Cuteri:  cuteri@th.physik.uni-frankfurt.de        #
#                                                                                        #
#----------------------------------------------------------------------------------------#

#Warning that the script is in developement phase!
printf "\n\e[38;5;11m \e[1m\e[4mWARNING\e[24m:\e[21m Script under developement! Do not use it!\e[0m\n\n"

#Sourcing auxiliary files
source AuxiliaryFunctions.sh || exit -2

#Needed variables

#Parse command line parameters
ParseCommandLineParameters $@

#Check if template for latex is present, if not or not complete, terminate and warn user





#TODO: 1) Put .tex files in TeX folder modifying the template
#         in order to input Packages.tex, Preamble.tex, Document.tex
#      2) Create functions to build each of the .tex above
#      3) Ingredients needed:
#          - Parser for Exercise file (extraction of user packages, commands)
#          - Logic with user variables for Preamble commands (e.g. lecture, prof, etc.)
#      4) Implement interactive part to choose exercise (suppose Pool folder
#         to be given by the user in a local variable)
#      5) Implement main part where the exercise are processed, the Sheet.tex
#         file is created, compiled and deleted (if everything fine, only .pdf should
#         be kept; maybe do compilation in separate folder so that the user can
#         investigate in case!?)
#
#NOTE: Ideally this git should be only a collection of tools. The user should
#      elsewhere create one or two localdefs files and then call this file from there.
#      Therefore, this script should look for the file with the localdefs from where it
#      is run (give default names and maybe make an option to change their name). 
#      If this file it is not found, a template should be created!
