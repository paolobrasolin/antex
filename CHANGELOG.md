# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2023-02-26

### Changed

- Lift restriction on required Ruby version to `< 3.1`.

### Fixed

- Solve `Psych::DisallowedClass` for ruby `>= 3.1` by explicitly allowing `Regexp` class.

## [0.1.4] - 2023-02-26

### Fixed

- Bound Ruby version to `< 3.1` to avoid confusing `Psych::DisallowedClass`.

## [0.1.3] - 2021-11-06

## [0.1.2] - 2017-10-01

## [0.1.1] - 2017-09-30

## [0.1.0] - 2017-09-30

[unreleased]: https://github.com/paolobrasolin/antex/compare/0.2.0...HEAD
[0.2.0]: https://github.com/paolobrasolin/antex/compare/0.1.4...0.2.0
[0.1.4]: https://github.com/paolobrasolin/antex/compare/0.1.3...0.1.4
[0.1.3]: https://github.com/paolobrasolin/antex/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/paolobrasolin/antex/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/paolobrasolin/antex/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/paolobrasolin/antex/releases/tag/0.1.0
