# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-07-01

### Added

- Initial release.
- Strict error handling with `set -euo pipefail`.
- Input file validation for existance and contains a version header.
- Extract latest version from CHANGELOG.md.
- Extract release notes for the latest detected version using awk. (if not unreleased)
- Early exit with success when version is 'Unreleased'.
- Parse keepachangelog version format from head and add it to github output.
  - `## [0.1.0] - 2026-07-01`
  - `## [0.1.0-alpha] - 2026-07-01`
- Comprehensive inline documentation.
- Bats test to make sure parsing correctly.
- Integration test to see exact parsing trough current CHANGELOG.md.
