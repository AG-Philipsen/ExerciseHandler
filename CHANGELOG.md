# Changelog

All notable changes to this project will be documented in this file.

This project does not adhere to [Semantic Versioning](http://semver.org/spec/v2.0.0.html), but it follows some aspects inspired from it.
In particular (even though this is not a strict, always respected rule), given a version number `X.Y`,
 - `Y` is incremented for minor changes (e.g. bug fixes) and 
 - `X` for major ones (e.g. new features).

Refer also to the [TODO](TODO.md) file to get more information of the changes occurred since the last release.

### Legend

 * :heavy_plus_sign: New feature
 * :heavy_check_mark: Enhancement
 * :sos: Bug fix
 * :heavy_minus_sign: Removed feature

---

## [Unreleased]

* :sos: Fixed minor bug in command line option parser. When no primary options were specified but still secondary ones were given, the script was terminating with a kind of obscure `bash` error. Now, in the same case, an understandable error is given to the user.
* :sos: Fixed minor bug which was triggered using the `-P` option without any existing final sheet. An error was given but the script was not exiting at that point.
* :heavy_check_mark: Now, producing temporary sheets that are *not* final, the same `pdf` file in the temporary folder is updated and not reopened if already open. A copy of each produced `pdf` file is still saved in the temporary folder.
* :heavy_check_mark: Using the option `-n 0`, sheets can start from zero. Now, in this scenario, the following is correctly created with 1 as sheet number (before this case was not considered and not working).
* :heavy_check_mark: Running the setup using the `-U` option leaves now the theme untouched in case it already exists. This allows to use the `-U` option to complete the working environment (e.g. creating missing empty folders) without the risk of loosing changes done on the theme (before there was not such a risk either, but the theme was moved to the `tmp` folder and this was not really ideal).
* :sos: :heavy_check_mark: Originally the secondary option `-x` was expected to be used together with the secondary option `-n`, however there was no check implemented to ensure the latter was also given. The script was terminating with an error because the inferred `sheetNumber` did not correspond to that of an existing sheet. One can now, instead, use `-x` without specifying a sheet number via `-n` if (s)he want to achieve the result that the sheet with the last(highest) `sheetNumber` is fixed.

---

## [Version 1.0] &nbsp;&nbsp; <sub><sup>23 March 2018</sub></sup>

This has been the first release of the repository.


[Unreleased]: https://github.com/AG-Philipsen/ExerciseHandler/compare/v1.0...HEAD
[Version 1.0]: https://github.com/AG-Philipsen/ExerciseHandler/releases/tag/v1.0
