# Claude Development Notes for dm Package

This file contains important notes and best practices for working with the dm package codebase.

## Development Environment

### Devcontainer Setup

This project uses a devcontainer with the image `ghcr.io/cynkra/docker-images/ubuntu24-rig-rrel-devtools-dm:latest`.

**Important**: All R commands and package operations should be executed within the devcontainer. Claude Code is configured to automatically use the devcontainer for all execution.

## Testing Guidelines

### Use test_local() with filter argument for specific test files

Always use the `filter` argument when running specific test files to avoid running all tests:

```r
# Run specific test files
testthat::test_local(filter = "flatten")     # Runs test-flatten.R

# Run all tests (only when necessary)
testthat::test_local()
```

**Important**: The `filter` argument filters by test file names, not individual test names within files.

---

*This file should be updated as new patterns are discovered.*
