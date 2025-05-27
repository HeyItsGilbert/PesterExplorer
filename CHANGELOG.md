# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

### Changed

- The `Show-PesterResult` List panel now the files using relative path from the
  current directory. It also added padding on the selected item as well as an
  additional icon to show the highlight.

### Fixed

- Removed extra item from the stack that tracked which layer of the view you
  were in.


## [0.1.0] Initial Version

### Added

- `Show-PesterResult` renders a TUI that let's you navigate your Pester run
  results. It shows item details as you navigate including the ability to from
  Container to Block to Test.
- `Show-PesterResultTree` renders your Pester run as a tree structure.
