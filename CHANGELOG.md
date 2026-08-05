# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0rc4] - UNRELEASED

### Changed

- Profile data are now in `profiles/all_profiles` and `profiles/mean_profiles`.
- Process variable data are now in `process_variables/all_profiles` and `process_variables/mean_profiles`.

## [v1.0.0rc3.post0] - 2026-08-01

### Fixed

- Fix parameter names of `examples/v1/dimless.ipynb`.
- `examples/v1/dimless.ipynb` now keeps `name` and `slurry` fields.

## [v1.0.0rc3] - 2026-07-31

### Changed

- HuggingFace Repository is moved to `heavyedge/profiles`.

## [v1.0.0rc2.post0] - 2026-07-31

### Added

- Notebooks can now be built with parameters using `papermill`.

## [v1.0.0rc2] - 2026-07-24

### Changed

- Process variables are now stored separately by dataset in `process_variables` directory, instead of being lumped in `pv.csv`.

## [v1.0.0rc1] - 2026-07-24

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
