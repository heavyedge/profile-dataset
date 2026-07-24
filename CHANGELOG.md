# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0rc2]

### Changed

- Process variables are now stored separately by dataset in `process_variables` directory, instead of being lumbed in `pv.csv`.

## [v1.0.0rc1]

### Changed

- Resource names in `datapackage.json` are changed for more human readable format.
- Mean profiles are now stored in `v1/mean_profiles` directory.
- Profiles are now distributed as `tar.gz` archives.

## [v1.0.0rc0] - 2026-07-24

Includes:

- Raw dataset v1

### Added

- v1
  - Preprocessed sets of profiles
  - Mean profiles of each set of profiles
  - Process variables
  - Viscosity measurement data
  - Contact angle measurement data
