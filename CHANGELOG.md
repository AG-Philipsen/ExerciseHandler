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

---

## [Version 1.0] &nbsp;&nbsp; <sub><sup>23 March 2018</sub></sup>

This has been the first release of the repository.


[Unreleased]: https://github.com/AG-Philipsen/ExerciseHandler/compare/v1.0...HEAD
[Version 1.0]: https://github.com/AG-Philipsen/ExerciseHandler/releases/tag/v1.0
