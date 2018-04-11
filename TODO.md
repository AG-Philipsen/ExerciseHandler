# To-do list

Here we keep track of work that is either planned to be done for the future or done in between two consecutive releases.
In particular, one can refer to the [Past work section](#past-work) to know about the changes that will be included in the next release.
Please, keep in mind that this is more a file for the developers than for the users and some statements in the following may sound cryptic.
Refer to the [CHANGELOG](https://github.com/AG-Philipsen/ExerciseHandler/blob/master/CHANGELOG.md) to read about notable changes to the project.

### Legend

* :new: Feature to be added
* :fire: Bug/inconsistency fixing
* :recycle: Refactoring
* :question: Decision making
* :memo: Documentation

----

## Future work

### High priority


### Normal priority

 - [ ] :new: Often, it happens that, producing a new sheet, several compilations are done after each other and, then, one quickly ends up with many `pdf` files opened in different windows. Since it is known that a not final sheet is opened from the `tmp` folder, it would be useful to close all open `pdf` files before opening a new one.
 - [ ] :new: :memo: Some users could not like to have a new `pdf` opened in a new window at each compilation and they could wish to have the same one updated. This could be implemented using a `pdf` file with a given, fixed name in the **`tmp`** folder, which would be updated at each time that the `ExerciseHandler` is invoqued with a new secondary option. Then, if such a `pdf` is already open, nothing is done, otherwise it is open. To update the fixed-name `pdf` file means to compile as usual in the `TemporaryCompilationFolder` and, then, to move the produced `pdf` to `tmp/fixedNameFile.pdf`.
 - [ ] :new: :memo: Add a secondary `-i` option to `-U` in order to *inherit* the exercises and the solutions from a previous lecture. Give the possibility to specify a path in which there should be an `Exercises`, `Solutions` and a `Figures` folder which are copied to the place from which `-U` is run. Add documentation (Wiki)
 - [ ] :memo: :question: It would be nice if figures used in sheets would be copied to the final folder. At the same time we did not come up with a good way to do this. Which figures should be copied? One could deduce them from the `.tex` files but different users could include them differently (e.g. wrap `\includegraphics` in an own macro)! Moreover `\graphicspath` should be changed and a fix of the sheet which is about fixing a figure is not immediate (we could not move from `Figures` to the final folder because otherwise the user should know that to fix (s)he should work in the final folder; we could still copy from `Figures` to the final folders and repeat this copy at each fix...). Is this what we want? Is it maintainable? Disuss this point in the documentation (Wiki).
 
 
### Low priority

 - [ ] :fire: :recycle: :new: Trap `CTRL-C` in a nice way: cleaning files/folders, etc. `->` DESIGN.
 - [ ] :fire: Use consistent exit error codes (now they are hard coded and without a meaning).
 - [ ] :question: Is it worth to make the handler fill the optional latex argument of the solution environment, if empty, reading it from the corresponding exercise?
 - [ ] :recycle: Refactor the LaTeX theme in order to give much more freedom to the user.
    * Each sheet should have a own `\Head` and a `\Sheet` command.
    * In the provided theme, where we use the same `\Head` across all sheets, we can implement an internal `\genericHead` command and use it in all the provided `\nameHead` commands.
 - [ ] :fire: :question: Use consistently quotation marks, in particular in filenames `->` consider possible spaces in filenames?!
 - [ ] :fire: Use only `printf`, no `echo`.
 - [ ] :question: Implement more pedantic checks on the `TexLocaldefs.tex` file to check that commands that should be there are indeed there?!
 - [ ] :question: Use `tikz` to "draw" tables instead of `pgfplotstable`?!
 This would solve the single line table exam problem, but it should be checked if all functionality can be guaranteed.
 - [ ] :new: Implement way to switch to different LaTeX compiler.
 - [ ] :question: Implement reordering of packages according to known rules to fix possible [LaTeX package conflicts](http://www.macfreek.nl/memory/LaTeX_package_conflicts#Unicode_in_Listing)?

----

## Past work
