# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive test suite using RSpec, VCR, and WebMock
- Tests for Client class including initialization, configuration, and fetch operations
- Tests for date filtering (start and fin parameters)
- Tests for API key configuration from class variable and options
- Testing documentation in README

### Fixed
- Fixed undefined variable `nm` in error message (now correctly uses `@tag`)
- Fixed README title from "EconDataReader" to "FredAsDataframe"
- Fixed configuration documentation to use `config.api_key` instead of `config.fred_api_key`
- Fixed Rakefile to properly define `:spec` task so `rake` command works

### Changed
- Updated gemspec to include test dependencies (rspec, vcr, webmock, rake)
- Improved README configuration section with clearer examples

## [0.1.1] - Previous Release

### Added
- Initial release with FRED data fetching functionality
- Support for Polars DataFrame output
- Date range filtering with start and fin parameters
- Hardcoded SP500 data for monthly frequency
