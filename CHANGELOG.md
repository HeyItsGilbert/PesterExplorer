# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.2] 2025-05-31

### Added

- Added tests for different private commands.

### Fixed

- Fixed for loop used to scroll which was using wrong variable.

## [0.3.1] 2025-05-30

### Added

- Add VIM (i.e. `hjkl`) navigation support.

### Fixed

- Add parameter validation and mandatory to ensure commands don't fail
  unexpectedly.

## [0.3.0] 2025-05-29

### Added

- Added the ability to scroll the preview pane on the right.
  - A "... more" line will show if you need to scroll.
  - This will give a warning if a panel can't completely rendered.
  - There is a known issue that you can "scroll past" the last item, but the
    last item will still render. You will need to scroll back up an equivalent
    number of times. This will be future Gilbert's problem.

### Changed

- Move test result breakdown chart to Preview pane.

## [0.2.0] 2025-05-28

### Added

- Added comment based help on private functions to make it easier for new
  contributors to grok.
- Added Pester result breakdown to title panel.

### Changed

- The `Show-PesterResult` List panel now the files using relative path from the
  current directory. It also added padding on the selected item as well as an
  additional icon to show the highlight.
- Formatted all the functions to stay under 80 character line limit. This is a
  preference. We will have a 120 hard limit (when possible).

### Fixed

- Removed extra item from the stack that tracked which layer of the view you
  were in.

## [0.1.0] Initial Version

### Added

- `Show-PesterResult` renders a TUI that let's you navigate your Pester run
  results. It shows item details as you navigate including the ability to from
  Container to Block to Test.
- `Show-PesterResultTree` renders your Pester run as a tree structure.
