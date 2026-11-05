# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-11-05

### Added

- `.env` preview with the keys aligned into a column, `=` and comments dimmed, blank lines preserved and `export` marked
- Key column padded to the longest key in the file (capped at 32 characters), so it does not jump while scrolling
- Patterns documented for `.env`, `.env.example`, `.env.local` and `foo.env` (Yazi matches `url` patterns against the full path)
- Files above 1 MB fall back to Yazi's code previewer
- `J`/`K` line scrolling

[0.1.0]: https://github.com/juanlopez4691/env-pretty.yazi/releases/tag/v0.1.0
