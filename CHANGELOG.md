# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-29

### Added
- Initial release of Vendorer gem
- `vendorer list` command to list all vendored gems
- `vendorer vendor` command to vendor a gem from GitHub
- `vendorer unvendor` command to remove a vendored gem
- `vendorer push` command to push changes to remote repository
- `vendorer status` command to show status of vendored gems
- `vendorer version` command to display version information
- Automatic Gemfile management (add/remove vendored gems)
- Git operations wrapper for clone, commit, push, and status
- Support for vendoring specific branches or tags
- Change detection for vendored gems
- RSpec test suite
- Cucumber feature tests
- Comprehensive documentation

### Features
- Clone gems from GitHub into `./vendor` directory
- Track local changes in vendored gems
- Push changes back to remote repositories
- Automatic Gemfile updates
- Safety checks to prevent data loss
- Clean unvendoring with change detection

[0.1.0]: https://github.com/vendorer/vendorer/releases/tag/v0.1.0
