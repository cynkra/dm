# Claude Development Notes for dm Package

This file contains important notes and best practices for working with the dm package codebase.

## Development Environment

### Devcontainer Setup

This project uses a devcontainer with the image `ghcr.io/cynkra/docker-images/ubuntu24-rig-rrel-devtools-dm:latest`.

**Important**: All R commands and package operations should be executed within the devcontainer. Claude Code is configured to automatically use the devcontainer for all execution.

## Coding Guidelines

- Format the code by running `air .` in the devcontainer.
- **Important**: Always add tests when fixing bugs to prevent regression. Test both the fix and edge cases.
- Prefer snapshot tests when testing console output.

## Testing Guidelines

Tests should be executed within the devcontainer using:

```bash
# Start devcontainer (if not already running)
devcontainer up --workspace-folder .

# Execute R commands in devcontainer
devcontainer exec --workspace-folder . R -e "testthat::test_local()"
```

### Use test_local() with filter argument for specific test files

Always use the `filter` argument when running specific test files to avoid running all tests:

```r
# Run specific test files
testthat::test_local(filter = "flatten")     # Example: Runs test-flatten.R

# Run all tests (always before finishing work)
testthat::test_local()
```

**Important**: The `filter` argument filters by test file names, not individual test names within files.

---

*This file should be updated as new patterns are discovered.*
