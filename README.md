# Exercise Handler

[![version][Release-badge]](CHANGELOG.md) [![license][License-badge]](LICENSE.md)
[![live][Live-badge]](https://github.com/AG-Philipsen/ExerciseHandler/releases/download/v1.0/ExerciseHandlerPresentation_v1.pdf)

The `Exercise Handler` is a tool to structure and automatise pretty much all of the tasks related to the organisation of tutorials for a given (e.g. academic) lecture by mostly producing, organising and compiling TeX files.

It makes it possible for you as tutor to devote your time to the sole content of exercises and solutions.
Writing new ones from scratch, or even just extending or reusing existing ones in the pool that will get populated while the `Exercise Handler` is used, possibly by many tutors, over the semesters.

At the same time, by making use of the `Exercise Handler`, you are not just trading your freedom in typesetting nice-looking customised exercise sheets for some more "spare" time.
On the contrary, you can implement your own theme, rather than using the provided classic one, and you can even profit from the provided support for different languages (:uk: :us: :de: :fr: :it:).


## Main Features

Interacting with the `Exercise Handler` main bash script, by specifying the appropriate command line option(s), it will be (as easy as) possible to achieve any of the possible tasks.

* A **set-up** of the "tutorial evironment" including a to-be-filled-in local definitions template, a (usable/customizable/replaceable) TeX theme file and the necessary folder structure.
* The creation of **new exercises** and (optionally) of the corresponding solutions, progressively populating a pool of exercises (and solutions).
* The creation of **exercise sheets** including any selection of exercises in the pool, to be delivered during the tutorial.
* The creation of **presence sheets** to be used during the tutorial as attendance register and/or to take note of the (self)evaluation of the delivered exercises.
* The creation of **solution sheets** for any given exercise sheet to be made public or just to use as guideline by tutors.
* The creation of **exam sheets** and of the **corresponding soluitions**.
* Getting a **list of already used exercises** according to already produced exercise sheets.
* **Exporting the work done** as tarball(s) in a ready-to-be-inherited fashion.
* **Inheriting previous work** in a ready-to-be-continued way.


## Getting Started

Being written in bash, the `Exercise Handler` does not need to be compiled or installed.
Once you will have cloned the repository, you will be able to run it straight away.

The script has a helper, that can be obtained using the `--help` option, providing a compact *getting started*.
For a complete overview you can refer to the [Wiki documentation](https://github.com/AG-Philipsen/Exercise_Handler/wiki) and in particular to [this page](https://github.com/AG-Philipsen/ExerciseHandler/wiki/How-it-works).

Running the `Exercise Handler` in **set-up** mode (with command line option `-U`) will allow you to configure it with the needed information, by filling up the produced local definitions template.
If this file is not filled out properly, you will be warned in successive runs.
In the set-up phase you will also choose a LaTeX theme, possibly the provided classic one or your own (after having read some detail in the relevant [Wiki page](https://github.com/AG-Philipsen/ExerciseHandler/wiki/The-LaTeX-theme)).


## Authors

The `Exercise Handler` has been developed since 2016 by a few [contributors](https://github.com/AG-Philipsen/ExerciseHandler/graphs/contributors) willing to be contacted by users for suggestions, feedbacks, bug reports, etc.


[Release-badge]: https://img.shields.io/badge/Last%20Release-v1.0-brightgreen.svg
[License-badge]: https://img.shields.io/badge/License-MIT-blue.svg
[Live-badge]: https://img.shields.io/badge/Live%20Example-v1.0-orange.svg
