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
testthat::test_local(filter = "zzx-deprecated")  # Runs test-zzx-deprecated.R

# Run all tests (only when necessary)
testthat::test_local()
```

**Important**: The `filter` argument filters by test file names, not individual test names within files.

### Running tests in devcontainer

When using Claude Code, tests should be executed within the devcontainer using:

```bash
# Start devcontainer (if not already running)
devcontainer up --workspace-folder .

# Execute R commands in devcontainer
devcontainer exec --workspace-folder . R -e "testthat::test_local(filter = 'flatten')"
```

### Common test filters

- `filter = "flatten"` - Tests for flattening functionality including `dm_squash_to_tbl()` deprecation
- `filter = "zzx-deprecated"` - Tests for all deprecated functions
- `filter = "test-name"` - Runs any test file matching `test-test-name.R`

---

*This file should be updated as new patterns are discovered.*
