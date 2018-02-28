##Exercise Handler

The `ExerciseHandler` is a tool to structure and automatize pretty much all of the tasks related to the organization of tutorials for a given (e.g. academic) lecture by mostly producing, organizing and compiling TeX files.

##Main Features

Interacting with the `ExerciseHandler` main bash script, by specifying the appropriate command line option(s), it will be (as easy as) possible to achieve:

* A **set up** of the "tutorial evironment" including a to-be-filled-in local definitions template, a (usable/customizable/replaceable) TeX theme file and the necessary folder structure.
* The creation of **new exercises** and (optionally) of the corresponding solutions, progressively populating a pool of exercises (and solutions).
* The creation of **exercise sheets**, including any selection of exercises in the pool, to be delivered during the tutorial.
* The creation of **presence sheets** to be used during the tutorial as attendance register and/or to take note of the (self)evaluation of the delivered exercises.
* The creation of **solution sheets** for any given exercise sheet to be made public or just to use as guideline by tutors.
* The creation of **exam sheets**.
* Getting a **list of already used exercises** according to already produced exercise sheets.

## Getting Started

Being written in bash, the `ExerciseHandler` does not need to be compiled or installed. Once you will have cloned the repository, you will be able to run it straight away.

The script has a helper, that can be obtained using the `--help` option, providing a compact *getting started*.
[//]: # (for a complete overview you can refer to the wiki documentation)


:exclamation: Consider that, to be able to properly work, the `ExerciseHandler` needs to be once run in **set up** mode (with command line option `-U`) so that it can then be configured with the needed information, by filling up the produced local definitions template. If this file is not filled out properly, you will be warned in successive runs. Also a custom TeX theme can be chosen in the set up phase. A classic one is provided.

## Authors
The `ExerciseHandler` has been developed since 2016 by a few [Contributors](https://github.com/AG-Philipsen/ExerciseHandler/contributors) willing to be contacted by users for suggestions, feedbacks, bug reports, etc.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

