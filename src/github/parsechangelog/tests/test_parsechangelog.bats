#!/usr/bin/env bats

# setup function runs before every single test
setup() {
  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0
  # as those will point to the bats executable's location
  # or the preprocessed file respectively
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  # make executables in src/ visible to PATH
  PATH="$DIR/../src:$PATH"

  # BATS_TEST_TMPDIR is auto created and cleaned by bats
  export GITHUB_OUTPUT="${BATS_TEST_TMPDIR}/github_output.env"
  export TEST_CHANGELOG="${BATS_TEST_TMPDIR}/CHANGELOG.md"
}

@test "can run our script" {
  # as we added src/ to $PATH, we can omit the relative path
  # to `src/parsechangelog.sh`.
  parsechangelog.sh
}

@test "Fails if CHANGELOG.md does not exist" {
  # run allows bats to capture exit codes and output without crashing
  run parsechangelog.sh "NON_EXISTENT_FILE.md"

  [ "$status" -eq 1 ]
  [[ "$output" == *"CHANGELOG.md not found"* ]]
}

@test "Extracts correct version and notes for standard release" {
  cat <<'EOF' >"$TEST_CHANGELOG"
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-06-07

2.0.0 is the first major revision of Keep a Changelog. It breaks the guidance, not the format: the six change types, `YYYY-MM-DD` dates, and the `Unreleased` and `[YANKED]` markers are all unchanged, so your existing changelog stays valid. What breaks is the surface around it. The page is restructured so some older section links no longer resolve, the recommended guidance has shifted, and existing translations are out of date until they catch up. The breaking changes are marked below.

### Added

- New guidance answering long-standing community questions:
  - Format: the `# Changelog` header preamble; marking breaking changes and
    where upgrade steps belong; choosing between Changed, Fixed, and Security;
    leading a Security entry with its CVE; why the six change types don't grow.
  - Versioning: schemes beyond SemVer, and linking each version to a `compare`
    diff with reference links.
  - Changelogs vs. release notes: how to derive one from the other without
    duplicate work, and why a host's generated notes are vendor lock-in.
  - Automation: LLM-drafted changelogs with a brief for an `AGENTS.md`;
    Conventional Commits; CI/CD; linking issues and pull requests; crediting
    contributors.
  - Scale: very large changelogs and monorepos.
  - Optional per-release summaries, and a statement of what Keep a Changelog
    deliberately won't do.
- A redesigned, accessible site (WCAG 2.1 AA) with light and dark themes.

### Changed

- **Breaking:** Retired the tagline "Don't let your friends dump git logs into changelogs" for "Clearly document the evolution of your projects." Earlier versions keep the original.
- **Breaking:** Restructured the page from a flat FAQ into integrated guidance, in a plainer, less first-person voice. Some older section links no longer resolve.
- Reframed the "GitHub Releases" answer as "Is a changelog the same as release notes?", broadened beyond GitHub to any host.
- Set page titles and descriptions from frontmatter, and fixed OpenGraph metadata so shared links render correctly and language-appropriately.

### Removed

- Outdated specifics (the Vandamme gem reference and a GitHub-Releases discoverability note) in favor of more general guidance.
- **Breaking:** The FAQ scaffolding and most first-person framing, whose section anchors no longer resolve; the podcast note now lives in the References section.

## [1.1.2] - 2024-09-27

### Added

- v1.1 German translation.
- v1.1 Italian translation.
- v1.1 Simplified Chinese translation.
- v1.1 Persian translation.
- v1.1 Polish translation.
- v1.1 Slovenian translation.
- v1.1 Traditional Chinese translation.
- v1.1 Spanish translation.
- v1.1 Brazilian Portuguese translation.
- v1.1 Czech translation.
- v1.1 Romanian translation.
- v1.1 Swedish translation.
- v1.1 Ukrainian translation.
- v1.1 Korean translation.
- v1.1 Indonesian translation.

### Fixed

- Improve French translation.
- Improve Dutch translation.

## [1.1.1] - 2023-03-05

### Added

- v1.1 Arabic translation.
- v1.1 French translation.
- v1.1 Dutch translation.
- v1.1 Russian translation.
- v1.1 Japanese translation.
- v1.1 Norwegian Bokmål translation.
- v1.1 "Inconsistent Changes" Turkish translation.
- Default to most recent versions available for each languages.
- Display count of available translations (26 to date!).
- Centralize all links into `/data/links.json` so they can be updated easily.

### Fixed

- Improve French translation.
- Improve id-ID translation.
- Improve Persian translation.
- Improve Russian translation.
- Improve Swedish title.
- Improve zh-CN translation.
- Improve French translation.
- Improve zh-TW translation.
- Improve Spanish (es-ES) transltion.
- Foldout menu in Dutch translation.
- Missing periods at the end of each change.
- Fix missing logo in 1.1 pages.
- Display notice when translation isn't for most recent version.
- Various broken links, page versions, and indentations.

### Changed

- Upgrade dependencies: Ruby 3.2.1, Middleman, etc.

### Removed

- Unused normalize.css file.
- Identical links assigned in each translation file.
- Duplicate index file for the english version.

## [1.1.0] - 2019-02-15

### Added

- Danish translation.
- Georgian translation from.
- Changelog inconsistency section in Bad Practices.

### Fixed

- Italian translation.
- Indonesian translation.

## [1.0.0] - 2017-06-20

### Added

- New visual identity by [@tylerfortune8].
- Version navigation.
- Links to latest released version in previous versions.
- "Why keep a changelog?" section.
- "Who needs a changelog?" section.
- "How do I make a changelog?" section.
- "Frequently Asked Questions" section.
- New "Guiding Principles" sub-section to "How do I make a changelog?".
- Simplified and Traditional Chinese translations from [@tianshuo].
- German translation from [@mpbzh] & [@Art4].
- Italian translation from [@azkidenz].
- Swedish translation from [@magol].
- Turkish translation from [@emreerkan].
- French translation from [@zapashcanon].
- Brazilian Portuguese translation from [@Webysther].
- Polish translation from [@amielucha] & [@m-aciek].
- Russian translation from [@aishek].
- Czech translation from [@h4vry].
- Slovak translation from [@jkostolansky].
- Korean translation from [@pierceh89].
- Croatian translation from [@porx].
- Persian translation from [@Hameds].
- Ukrainian translation from [@osadchyi-s].

### Changed

- Start using "changelog" over "change log" since it's the common usage.
- Start versioning based on the current English version at 0.3.0 to help translation authors keep things up-to-date.
- Rewrite "What makes unicorns cry?" section.
- Rewrite "Ignoring Deprecations" sub-section to clarify the ideal scenario.
- Improve "Commit log diffs" sub-section to further argument against them.
- Merge "Why can’t people just use a git log diff?" with "Commit log diffs".
- Fix typos in Simplified Chinese and Traditional Chinese translations.
- Fix typos in Brazilian Portuguese translation.
- Fix typos in Turkish translation.
- Fix typos in Czech translation.
- Fix typos in Swedish translation.
- Improve phrasing in French translation.
- Fix phrasing and spelling in German translation.

### Removed

- Section about "changelog" vs "CHANGELOG".

## [0.3.0] - 2015-12-03

### Added

- RU translation from [@aishek].
- pt-BR translation from [@tallesl].
- es-ES translation from [@ZeliosAriex].

## [0.2.0] - 2015-10-06

### Changed

- Remove exclusionary mentions of "open source" since this project can benefit both "open" and "closed" source projects equally.

## [0.1.0] - 2015-10-06

### Added

- Answer "Should you ever rewrite a change log?".

### Changed

- Improve argument against commit logs.
- Start following [SemVer] properly.

## [0.0.8] - 2015-02-17

### Changed

- Update year to match in every README example.
- Reluctantly stop making fun of Brits only, since most of the world writes dates in a strange way.

### Fixed

- Fix typos in recent README changes.
- Update outdated unreleased diff link.

## [0.0.7] - 2015-02-16

### Added

- Link, and make it obvious that date format is ISO 8601.

### Changed

- Clarified the section on "Is there a standard change log format?".

### Fixed

- Fix Markdown links to tag comparison URL with footnote-style links.

## [0.0.6] - 2014-12-12

### Added

- README section on "yanked" releases.

## [0.0.5] - 2014-08-09

### Added

- Markdown links to version tags on release headings.
- Unreleased section to gather unreleased changes and encourage note keeping prior to releases.

## [0.0.4] - 2014-08-09

### Added

- Better explanation of the difference between the file ("CHANGELOG") and its function "the change log".

### Changed

- Refer to a "change log" instead of a "CHANGELOG" throughout the site to differentiate between the file and the purpose of the file — the logging of changes.

### Removed

- Remove empty sections from CHANGELOG, they occupy too much space and create too much noise in the file. People will have to assume that the missing sections were intentionally left out because they contained no notable changes.

## [0.0.3] - 2014-08-09

### Added

- "Why should I care?" section mentioning The Changelog podcast.

## [0.0.2] - 2014-07-10

### Added

- Explanation of the recommended reverse chronological release ordering.

## [0.0.1] - 2014-05-31

### Added

- This CHANGELOG file to hopefully serve as an evolving example of a standardized open source project CHANGELOG.
- CNAME file to enable GitHub Pages custom domain.
- README now contains answers to common questions about CHANGELOGs.
- Good examples and basic guidelines, including proper date formatting.
- Counter-examples: "What makes unicorns cry?".

[unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v2.0.0...HEAD [2.0.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.2...v2.0.0 [1.1.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.1...v1.1.2 [1.1.1]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.0...v1.1.1 [1.1.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...v1.1.0 [1.0.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.0...v1.0.0 [0.3.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.0...v0.3.0 [0.2.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.0...v0.2.0 [0.1.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.8...v0.1.0 [0.0.8]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.7...v0.0.8 [0.0.7]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.6...v0.0.7 [0.0.6]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.5...v0.0.6 [0.0.5]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.4...v0.0.5 [0.0.4]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.3...v0.0.4 [0.0.3]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.2...v0.0.3 [0.0.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2 [0.0.1]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/v0.0.1 [SemVer]: https://semver.org [@tylerfortune8]: https://github.com/tylerfortune8 [@tianshuo]: https://github.com/tianshuo [@mpbzh]: https://github.com/mpbzh [@Art4]: https://github.com/Art4 [@azkidenz]: https://github.com/azkidenz [@magol]: https://github.com/magol [@emreerkan]: https://github.com/emreerkan [@zapashcanon]: https://github.com/zapashcanon [@Webysther]: https://github.com/Webysther [@amielucha]: https://github.com/amielucha [@m-aciek]: https://github.com/m-aciek [@aishek]: https://github.com/aishek [@h4vry]: https://github.com/h4vry [@jkostolansky]: https://github.com/jkostolansky [@pierceh89]: https://github.com/pierceh89 [@porx]: https://github.com/porx [@Hameds]: https://github.com/Hameds [@osadchyi-s]: https://github.com/osadchyi-s [@tallesl]: https://github.com/tallesl [@ZeliosAriex]: https://github.com/ZeliosAriex
EOF

  run parsechangelog.sh "$TEST_CHANGELOG"

  [ "$status" -eq 0 ]

  # check if veresion was correctly exported to GITHUB_OUTPUT
  grep -q "version=2.0.0" "$GITHUB_OUTPUT"

  # check if the notes section was extracted (ignoring the EOF delimeter logic for a moment)
  grep -q "New guidance answering long-standing community questions:" "$GITHUB_OUTPUT"

  # ensure it didn't extract the old version's notes
  ! grep -q "v1.1 German translation." "$GITHUB_OUTPUT"
}

@test "Handles [Unreleased] tag correctly and exits early" {
  cat <<'EOF' >"$TEST_CHANGELOG"
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Turkish language translation

## [2.0.0] - 2026-06-07

2.0.0 is the first major revision of Keep a Changelog. It breaks the guidance, not the format: the six change types, `YYYY-MM-DD` dates, and the `Unreleased` and `[YANKED]` markers are all unchanged, so your existing changelog stays valid. What breaks is the surface around it. The page is restructured so some older section links no longer resolve, the recommended guidance has shifted, and existing translations are out of date until they catch up. The breaking changes are marked below.

### Added

- New guidance answering long-standing community questions:
  - Format: the `# Changelog` header preamble; marking breaking changes and
    where upgrade steps belong; choosing between Changed, Fixed, and Security;
    leading a Security entry with its CVE; why the six change types don't grow.
  - Versioning: schemes beyond SemVer, and linking each version to a `compare`
    diff with reference links.
  - Changelogs vs. release notes: how to derive one from the other without
    duplicate work, and why a host's generated notes are vendor lock-in.
  - Automation: LLM-drafted changelogs with a brief for an `AGENTS.md`;
    Conventional Commits; CI/CD; linking issues and pull requests; crediting
    contributors.
  - Scale: very large changelogs and monorepos.
  - Optional per-release summaries, and a statement of what Keep a Changelog
    deliberately won't do.
- A redesigned, accessible site (WCAG 2.1 AA) with light and dark themes.

### Changed

- **Breaking:** Retired the tagline "Don't let your friends dump git logs into changelogs" for "Clearly document the evolution of your projects." Earlier versions keep the original.
- **Breaking:** Restructured the page from a flat FAQ into integrated guidance, in a plainer, less first-person voice. Some older section links no longer resolve.
- Reframed the "GitHub Releases" answer as "Is a changelog the same as release notes?", broadened beyond GitHub to any host.
- Set page titles and descriptions from frontmatter, and fixed OpenGraph metadata so shared links render correctly and language-appropriately.

### Removed

- Outdated specifics (the Vandamme gem reference and a GitHub-Releases discoverability note) in favor of more general guidance.
- **Breaking:** The FAQ scaffolding and most first-person framing, whose section anchors no longer resolve; the podcast note now lives in the References section.

## [1.1.2] - 2024-09-27

### Added

- v1.1 German translation.
- v1.1 Italian translation.
- v1.1 Simplified Chinese translation.
- v1.1 Persian translation.
- v1.1 Polish translation.
- v1.1 Slovenian translation.
- v1.1 Traditional Chinese translation.
- v1.1 Spanish translation.
- v1.1 Brazilian Portuguese translation.
- v1.1 Czech translation.
- v1.1 Romanian translation.
- v1.1 Swedish translation.
- v1.1 Ukrainian translation.
- v1.1 Korean translation.
- v1.1 Indonesian translation.

### Fixed

- Improve French translation.
- Improve Dutch translation.

## [1.1.1] - 2023-03-05

### Added

- v1.1 Arabic translation.
- v1.1 French translation.
- v1.1 Dutch translation.
- v1.1 Russian translation.
- v1.1 Japanese translation.
- v1.1 Norwegian Bokmål translation.
- v1.1 "Inconsistent Changes" Turkish translation.
- Default to most recent versions available for each languages.
- Display count of available translations (26 to date!).
- Centralize all links into `/data/links.json` so they can be updated easily.

### Fixed

- Improve French translation.
- Improve id-ID translation.
- Improve Persian translation.
- Improve Russian translation.
- Improve Swedish title.
- Improve zh-CN translation.
- Improve French translation.
- Improve zh-TW translation.
- Improve Spanish (es-ES) transltion.
- Foldout menu in Dutch translation.
- Missing periods at the end of each change.
- Fix missing logo in 1.1 pages.
- Display notice when translation isn't for most recent version.
- Various broken links, page versions, and indentations.

### Changed

- Upgrade dependencies: Ruby 3.2.1, Middleman, etc.

### Removed

- Unused normalize.css file.
- Identical links assigned in each translation file.
- Duplicate index file for the english version.

## [1.1.0] - 2019-02-15

### Added

- Danish translation.
- Georgian translation from.
- Changelog inconsistency section in Bad Practices.

### Fixed

- Italian translation.
- Indonesian translation.

## [1.0.0] - 2017-06-20

### Added

- New visual identity by [@tylerfortune8].
- Version navigation.
- Links to latest released version in previous versions.
- "Why keep a changelog?" section.
- "Who needs a changelog?" section.
- "How do I make a changelog?" section.
- "Frequently Asked Questions" section.
- New "Guiding Principles" sub-section to "How do I make a changelog?".
- Simplified and Traditional Chinese translations from [@tianshuo].
- German translation from [@mpbzh] & [@Art4].
- Italian translation from [@azkidenz].
- Swedish translation from [@magol].
- Turkish translation from [@emreerkan].
- French translation from [@zapashcanon].
- Brazilian Portuguese translation from [@Webysther].
- Polish translation from [@amielucha] & [@m-aciek].
- Russian translation from [@aishek].
- Czech translation from [@h4vry].
- Slovak translation from [@jkostolansky].
- Korean translation from [@pierceh89].
- Croatian translation from [@porx].
- Persian translation from [@Hameds].
- Ukrainian translation from [@osadchyi-s].

### Changed

- Start using "changelog" over "change log" since it's the common usage.
- Start versioning based on the current English version at 0.3.0 to help translation authors keep things up-to-date.
- Rewrite "What makes unicorns cry?" section.
- Rewrite "Ignoring Deprecations" sub-section to clarify the ideal scenario.
- Improve "Commit log diffs" sub-section to further argument against them.
- Merge "Why can’t people just use a git log diff?" with "Commit log diffs".
- Fix typos in Simplified Chinese and Traditional Chinese translations.
- Fix typos in Brazilian Portuguese translation.
- Fix typos in Turkish translation.
- Fix typos in Czech translation.
- Fix typos in Swedish translation.
- Improve phrasing in French translation.
- Fix phrasing and spelling in German translation.

### Removed

- Section about "changelog" vs "CHANGELOG".

## [0.3.0] - 2015-12-03

### Added

- RU translation from [@aishek].
- pt-BR translation from [@tallesl].
- es-ES translation from [@ZeliosAriex].

## [0.2.0] - 2015-10-06

### Changed

- Remove exclusionary mentions of "open source" since this project can benefit both "open" and "closed" source projects equally.

## [0.1.0] - 2015-10-06

### Added

- Answer "Should you ever rewrite a change log?".

### Changed

- Improve argument against commit logs.
- Start following [SemVer] properly.

## [0.0.8] - 2015-02-17

### Changed

- Update year to match in every README example.
- Reluctantly stop making fun of Brits only, since most of the world writes dates in a strange way.

### Fixed

- Fix typos in recent README changes.
- Update outdated unreleased diff link.

## [0.0.7] - 2015-02-16

### Added

- Link, and make it obvious that date format is ISO 8601.

### Changed

- Clarified the section on "Is there a standard change log format?".

### Fixed

- Fix Markdown links to tag comparison URL with footnote-style links.

## [0.0.6] - 2014-12-12

### Added

- README section on "yanked" releases.

## [0.0.5] - 2014-08-09

### Added

- Markdown links to version tags on release headings.
- Unreleased section to gather unreleased changes and encourage note keeping prior to releases.

## [0.0.4] - 2014-08-09

### Added

- Better explanation of the difference between the file ("CHANGELOG") and its function "the change log".

### Changed

- Refer to a "change log" instead of a "CHANGELOG" throughout the site to differentiate between the file and the purpose of the file — the logging of changes.

### Removed

- Remove empty sections from CHANGELOG, they occupy too much space and create too much noise in the file. People will have to assume that the missing sections were intentionally left out because they contained no notable changes.

## [0.0.3] - 2014-08-09

### Added

- "Why should I care?" section mentioning The Changelog podcast.

## [0.0.2] - 2014-07-10

### Added

- Explanation of the recommended reverse chronological release ordering.

## [0.0.1] - 2014-05-31

### Added

- This CHANGELOG file to hopefully serve as an evolving example of a standardized open source project CHANGELOG.
- CNAME file to enable GitHub Pages custom domain.
- README now contains answers to common questions about CHANGELOGs.
- Good examples and basic guidelines, including proper date formatting.
- Counter-examples: "What makes unicorns cry?".

[unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v2.0.0...HEAD [2.0.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.2...v2.0.0 [1.1.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.1...v1.1.2 [1.1.1]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.0...v1.1.1 [1.1.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...v1.1.0 [1.0.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.0...v1.0.0 [0.3.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.0...v0.3.0 [0.2.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.0...v0.2.0 [0.1.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.8...v0.1.0 [0.0.8]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.7...v0.0.8 [0.0.7]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.6...v0.0.7 [0.0.6]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.5...v0.0.6 [0.0.5]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.4...v0.0.5 [0.0.4]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.3...v0.0.4 [0.0.3]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.2...v0.0.3 [0.0.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2 [0.0.1]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/v0.0.1 [SemVer]: https://semver.org [@tylerfortune8]: https://github.com/tylerfortune8 [@tianshuo]: https://github.com/tianshuo [@mpbzh]: https://github.com/mpbzh [@Art4]: https://github.com/Art4 [@azkidenz]: https://github.com/azkidenz [@magol]: https://github.com/magol [@emreerkan]: https://github.com/emreerkan [@zapashcanon]: https://github.com/zapashcanon [@Webysther]: https://github.com/Webysther [@amielucha]: https://github.com/amielucha [@m-aciek]: https://github.com/m-aciek [@aishek]: https://github.com/aishek [@h4vry]: https://github.com/h4vry [@jkostolansky]: https://github.com/jkostolansky [@pierceh89]: https://github.com/pierceh89 [@porx]: https://github.com/porx [@Hameds]: https://github.com/Hameds [@osadchyi-s]: https://github.com/osadchyi-s [@tallesl]: https://github.com/tallesl [@ZeliosAriex]: https://github.com/ZeliosAriex
EOF

  run parsechangelog.sh "$TEST_CHANGELOG"

  # script should exit success via 0 when it skips unreleased
  [ "$status" -eq 0 ]

  # check that it correctly flagged it as unrelease in the github output
  grep -q "is_unreleased=true" "$GITHUB_OUTPUT"
}

@test "Extracts correct version and notes for alpha/beta releases" {
  cat <<'EOF' >"$TEST_CHANGELOG"
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0-alpha] - 2026-06-07

2.0.0 is the first major revision of Keep a Changelog. It breaks the guidance, not the format: the six change types, `YYYY-MM-DD` dates, and the `Unreleased` and `[YANKED]` markers are all unchanged, so your existing changelog stays valid. What breaks is the surface around it. The page is restructured so some older section links no longer resolve, the recommended guidance has shifted, and existing translations are out of date until they catch up. The breaking changes are marked below.

### Added

- New guidance answering long-standing community questions:
  - Format: the `# Changelog` header preamble; marking breaking changes and
    where upgrade steps belong; choosing between Changed, Fixed, and Security;
    leading a Security entry with its CVE; why the six change types don't grow.
  - Versioning: schemes beyond SemVer, and linking each version to a `compare`
    diff with reference links.
  - Changelogs vs. release notes: how to derive one from the other without
    duplicate work, and why a host's generated notes are vendor lock-in.
  - Automation: LLM-drafted changelogs with a brief for an `AGENTS.md`;
    Conventional Commits; CI/CD; linking issues and pull requests; crediting
    contributors.
  - Scale: very large changelogs and monorepos.
  - Optional per-release summaries, and a statement of what Keep a Changelog
    deliberately won't do.
- A redesigned, accessible site (WCAG 2.1 AA) with light and dark themes.

### Changed

- **Breaking:** Retired the tagline "Don't let your friends dump git logs into changelogs" for "Clearly document the evolution of your projects." Earlier versions keep the original.
- **Breaking:** Restructured the page from a flat FAQ into integrated guidance, in a plainer, less first-person voice. Some older section links no longer resolve.
- Reframed the "GitHub Releases" answer as "Is a changelog the same as release notes?", broadened beyond GitHub to any host.
- Set page titles and descriptions from frontmatter, and fixed OpenGraph metadata so shared links render correctly and language-appropriately.

### Removed

- Outdated specifics (the Vandamme gem reference and a GitHub-Releases discoverability note) in favor of more general guidance.
- **Breaking:** The FAQ scaffolding and most first-person framing, whose section anchors no longer resolve; the podcast note now lives in the References section.

## [1.1.2] - 2024-09-27

### Added

- v1.1 German translation.
- v1.1 Italian translation.
- v1.1 Simplified Chinese translation.
- v1.1 Persian translation.
- v1.1 Polish translation.
- v1.1 Slovenian translation.
- v1.1 Traditional Chinese translation.
- v1.1 Spanish translation.
- v1.1 Brazilian Portuguese translation.
- v1.1 Czech translation.
- v1.1 Romanian translation.
- v1.1 Swedish translation.
- v1.1 Ukrainian translation.
- v1.1 Korean translation.
- v1.1 Indonesian translation.

### Fixed

- Improve French translation.
- Improve Dutch translation.

## [1.1.1] - 2023-03-05

### Added

- v1.1 Arabic translation.
- v1.1 French translation.
- v1.1 Dutch translation.
- v1.1 Russian translation.
- v1.1 Japanese translation.
- v1.1 Norwegian Bokmål translation.
- v1.1 "Inconsistent Changes" Turkish translation.
- Default to most recent versions available for each languages.
- Display count of available translations (26 to date!).
- Centralize all links into `/data/links.json` so they can be updated easily.

### Fixed

- Improve French translation.
- Improve id-ID translation.
- Improve Persian translation.
- Improve Russian translation.
- Improve Swedish title.
- Improve zh-CN translation.
- Improve French translation.
- Improve zh-TW translation.
- Improve Spanish (es-ES) transltion.
- Foldout menu in Dutch translation.
- Missing periods at the end of each change.
- Fix missing logo in 1.1 pages.
- Display notice when translation isn't for most recent version.
- Various broken links, page versions, and indentations.

### Changed

- Upgrade dependencies: Ruby 3.2.1, Middleman, etc.

### Removed

- Unused normalize.css file.
- Identical links assigned in each translation file.
- Duplicate index file for the english version.


[unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v2.0.0...HEAD [2.0.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.2...v2.0.0 [1.1.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.1...v1.1.2 [1.1.1]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.1.0...v1.1.1 [1.1.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...v1.1.0 [1.0.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.0...v1.0.0 [0.3.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.0...v0.3.0 [0.2.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.0...v0.2.0 [0.1.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.8...v0.1.0 [0.0.8]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.7...v0.0.8 [0.0.7]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.6...v0.0.7 [0.0.6]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.5...v0.0.6 [0.0.5]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.4...v0.0.5 [0.0.4]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.3...v0.0.4 [0.0.3]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.2...v0.0.3 [0.0.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2 [0.0.1]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/v0.0.1 [SemVer]: https://semver.org [@tylerfortune8]: https://github.com/tylerfortune8 [@tianshuo]: https://github.com/tianshuo [@mpbzh]: https://github.com/mpbzh [@Art4]: https://github.com/Art4 [@azkidenz]: https://github.com/azkidenz [@magol]: https://github.com/magol [@emreerkan]: https://github.com/emreerkan [@zapashcanon]: https://github.com/zapashcanon [@Webysther]: https://github.com/Webysther [@amielucha]: https://github.com/amielucha [@m-aciek]: https://github.com/m-aciek [@aishek]: https://github.com/aishek [@h4vry]: https://github.com/h4vry [@jkostolansky]: https://github.com/jkostolansky [@pierceh89]: https://github.com/pierceh89 [@porx]: https://github.com/porx [@Hameds]: https://github.com/Hameds [@osadchyi-s]: https://github.com/osadchyi-s [@tallesl]: https://github.com/tallesl [@ZeliosAriex]: https://github.com/ZeliosAriex
EOF

  run parsechangelog.sh "$TEST_CHANGELOG"

  [ "$status" -eq 0 ]

  # check if veresion was correctly exported to GITHUB_OUTPUT
  grep -q "version=2.0.0-alpha" "$GITHUB_OUTPUT"

  # check if the notes section was extracted (ignoring the EOF delimeter logic for a moment)
  grep -q "New guidance answering long-standing community questions:" "$GITHUB_OUTPUT"
  grep -Fq -- "- **Breaking:** The FAQ scaffolding and most first-person framing, whose section anchors no longer resolve; the podcast note now lives in the References section." "$GITHUB_OUTPUT"

  # ensure it didn't extract the old version's notes
  ! grep -q "v1.1 German translation." "$GITHUB_OUTPUT"
}

@test "Extracts the complete multiline block for alpha releases" {
  export EXPECTED_NOTES="${BATS_TEST_TMPDIR}/expected.md"
  export ACTUAL_NOTES="${BATS_TEST_TMPDIR}/actual.md"

  # 1. Setup the dummy CHANGELOG with the 2.0.0-alpha block
  cat <<'EOF' >"$TEST_CHANGELOG"
# Changelog

## [2.0.0-alpha] - 2026-06-07

2.0.0 is the first major revision of Keep a Changelog. It breaks the guidance, not the format: the six change types, `YYYY-MM-DD` dates, and the `Unreleased` and `[YANKED]` markers are all unchanged, so your existing changelog stays valid. What breaks is the surface around it. The page is restructured so some older section links no longer resolve, the recommended guidance has shifted, and existing translations are out of date until they catch up. The breaking changes are marked below.

### Added

- New guidance answering long-standing community questions:
  - Format: the `# Changelog` header preamble; marking breaking changes and
    where upgrade steps belong; choosing between Changed, Fixed, and Security;
    leading a Security entry with its CVE; why the six change types don't grow.
  - Versioning: schemes beyond SemVer, and linking each version to a `compare`
    diff with reference links.
  - Changelogs vs. release notes: how to derive one from the other without
    duplicate work, and why a host's generated notes are vendor lock-in.
  - Automation: LLM-drafted changelogs with a brief for an `AGENTS.md`;
    Conventional Commits; CI/CD; linking issues and pull requests; crediting
    contributors.
  - Scale: very large changelogs and monorepos.
  - Optional per-release summaries, and a statement of what Keep a Changelog
    deliberately won't do.
- A redesigned, accessible site (WCAG 2.1 AA) with light and dark themes.

### Changed

- **Breaking:** Retired the tagline "Don't let your friends dump git logs into changelogs" for "Clearly document the evolution of your projects." Earlier versions keep the original.
- **Breaking:** Restructured the page from a flat FAQ into integrated guidance, in a plainer, less first-person voice. Some older section links no longer resolve.
- Reframed the "GitHub Releases" answer as "Is a changelog the same as release notes?", broadened beyond GitHub to any host.
- Set page titles and descriptions from frontmatter, and fixed OpenGraph metadata so shared links render correctly and language-appropriately.

### Removed

- Outdated specifics (the Vandamme gem reference and a GitHub-Releases discoverability note) in favor of more general guidance.
- **Breaking:** The FAQ scaffolding and most first-person framing, whose section anchors no longer resolve; the podcast note now lives in the References section.

## [1.0.0] - 2020-01-01
### Added
- Some old feature that should not be extracted.
EOF

  # 2. Define exactly what the output SHOULD look like
  # Note: your awk script leaves a leading blank line, so we match that here.
  cat <<'EOF' >"$EXPECTED_NOTES"

2.0.0 is the first major revision of Keep a Changelog. It breaks the guidance, not the format: the six change types, `YYYY-MM-DD` dates, and the `Unreleased` and `[YANKED]` markers are all unchanged, so your existing changelog stays valid. What breaks is the surface around it. The page is restructured so some older section links no longer resolve, the recommended guidance has shifted, and existing translations are out of date until they catch up. The breaking changes are marked below.

### Added

- New guidance answering long-standing community questions:
  - Format: the `# Changelog` header preamble; marking breaking changes and
    where upgrade steps belong; choosing between Changed, Fixed, and Security;
    leading a Security entry with its CVE; why the six change types don't grow.
  - Versioning: schemes beyond SemVer, and linking each version to a `compare`
    diff with reference links.
  - Changelogs vs. release notes: how to derive one from the other without
    duplicate work, and why a host's generated notes are vendor lock-in.
  - Automation: LLM-drafted changelogs with a brief for an `AGENTS.md`;
    Conventional Commits; CI/CD; linking issues and pull requests; crediting
    contributors.
  - Scale: very large changelogs and monorepos.
  - Optional per-release summaries, and a statement of what Keep a Changelog
    deliberately won't do.
- A redesigned, accessible site (WCAG 2.1 AA) with light and dark themes.

### Changed

- **Breaking:** Retired the tagline "Don't let your friends dump git logs into changelogs" for "Clearly document the evolution of your projects." Earlier versions keep the original.
- **Breaking:** Restructured the page from a flat FAQ into integrated guidance, in a plainer, less first-person voice. Some older section links no longer resolve.
- Reframed the "GitHub Releases" answer as "Is a changelog the same as release notes?", broadened beyond GitHub to any host.
- Set page titles and descriptions from frontmatter, and fixed OpenGraph metadata so shared links render correctly and language-appropriately.

### Removed

- Outdated specifics (the Vandamme gem reference and a GitHub-Releases discoverability note) in favor of more general guidance.
- **Breaking:** The FAQ scaffolding and most first-person framing, whose section anchors no longer resolve; the podcast note now lives in the References section.
EOF

  # 3. Execute the script
  run parsechangelog.sh "$TEST_CHANGELOG"
  [ "$status" -eq 0 ]

  # 4. Extract ONLY the multiline payload from the GITHUB_OUTPUT file
  # This uses the same logic from your integration test to bypass the dynamic `EOF` base64 string
  awk '
    /^notes<</ { delimiter = substr($0, 8); capture = 1; next; }
    capture == 1 && $0 == delimiter { capture = 0; next; }
    capture == 1 { print; }
  ' "$GITHUB_OUTPUT" >"$ACTUAL_NOTES"

  # 5. Compare the files using diff.
  # If they don't match exactly, the test fails, and bats prints the diff.
  run diff -u "$EXPECTED_NOTES" "$ACTUAL_NOTES"

  # Print the diff output if the test fails so you can see what went wrong
  if [ "$status" -ne 0 ]; then
    echo "Files differ! Here is the diff:"
    echo "$output"
  fi

  [ "$status" -eq 0 ]
}
