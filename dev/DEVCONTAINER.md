# Claude Development Notes for dm Package

This file contains important notes and best practices for working with
the dm package codebase.

## Development Environment

### Devcontainer Setup

This project uses a devcontainer configuration with:

- **R Environment**:
  `ghcr.io/cynkra/docker-images/ubuntu24-rig-rrel-dc-dt-dm:latest`
- **PostgreSQL Database**: Latest PostgreSQL with socket connection
  support
- **MariaDB Database**: Latest MariaDB for testing database
  compatibility
- **Docker Compose**: `.devcontainer/docker-compose.yml` defines the
  complete environment

**Important**: All R commands and package operations should be executed
within the devcontainer. Claude Code is configured to automatically use
the devcontainer for all execution.

## Coding Guidelines

- Format the code by running `air format .` in the devcontainer.
- **Important**: Always add tests when fixing bugs to prevent
  regression. Test both the fix and edge cases.
- Prefer snapshot tests when testing console output.

## Testing Guidelines

Tests should be executed within the devcontainer using:

``` bash
# Start devcontainer (if not already running)
devcontainer up --workspace-folder .

# Restart devcontainer after configuration changes
devcontainer up --workspace-folder . --remove-existing-container

# Execute R commands in devcontainer
devcontainer exec --workspace-folder . R -e 'testthat::test_local(reporter = "summary")'
```

### Use test_local()

Always use `reporter = "summary"` when running tests to get a concise
output. Always use the `filter` argument when running specific test
files to avoid running all tests:

``` r
# Run specific test files
testthat::test_local(filter = "flatten", reporter = "summary")     # Example: Runs test-flatten.R

# Run all tests (always before finishing work)
testthat::test_local(reporter = "summary")
```

**Important**: The `filter` argument filters by test file names, not
individual test names within files.

### Different Backends

**Important**: Set the `DM_TEST_SRC` environment variable to test
against various backends. Always test all backends. Supported values
include:

- `df`
- `postgres`
- `maria` (MariaDB)
- `mssql` (SQL Server)
- `duckdb`

------------------------------------------------------------------------

*This file should be updated as new patterns are discovered.*
