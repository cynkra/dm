# AI Agent Development Guidelines for dm

> **Note**: For GitHub Copilot-specific instructions, see
> [`.github/copilot-instructions.md`](https://dm.cynkra.com/dev/copilot-instructions.md).

## Project Overview

The dm package provides a framework for working with multiple related
data frames or lazy tables in R, allowing users to define, manipulate,
and visualize relationships between tables (similar to a database
schema). It supports operations such as joins, filtering, and data
integrity checks across multiple tables.

## Key Technologies

- **Language**: Plain R
- **Testing**: testthat framework
- **Documentation**: roxygen2 with Markdown syntax
- **Code Formatting**: air (R formatting tool)
- **Build System**: R CMD, devtools
- **Code Generation**: During
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html),
  in `helper-sync.R`

## Development Setup

### Installation and Dependencies

``` r
# Install all dependencies
pak::pak()
# Install build dependencies
pak::pak(dependencies = "Config/Needs/build")
```

### Install and run R

- When run on GitHub Actions, assume that R, the package in its current
  state and all dependencies are installed.
- Only install new packages when needed for implementing new features or
  tests.
- Run `R -q -e 'devtools::check()'` to execute all checks as a final
  step.

### Building and Testing

- Load package for development:
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
- Run tests: `testthat::test_local(reporter = "check")`
- Run tests for a single file `test-foo.R`:
  `testthat::test_local(filter = "foo", reporter = "check")`
- Build package: `devtools::build()`
- Check package: `devtools::check()`
- Update `.Rd` documentation: `devtools::document()`
- Format code: `air format .`

## Code Style and Documentation

### PR and Commit Style

- IMPORTANT: PR titles end up in `NEWS.md` grouped by conventional
  commit label. PRs and commits use the conventional commit style with
  backticks for code references such as `function_call()`
- PRs are generally squashed, a clean history within a PR is not
  necessary

### Comment Style

- Prefer expressive code over comments where possible
- Add comments to utility functions that cannot be made immediately
  obvious
- Focus comments on explaining the “why” and “how”, the “what” should be
  clear from the code itself
- Use line breaks after each sentence

### R Code Conventions

- Follow the [tidyverse style guide](https://style.tidyverse.org) and
  the [tidyverse design guide](https://design.tidyverse.org)
- Use `snake_case` for new functions
- Use explicit package prefixes (e.g.,
  [`withr::local_db_connection()`](https://withr.r-lib.org/reference/with_db_connection.html))
  for clarity
- Maintain consistent indentation (2 spaces) and spacing patterns
- Use meaningful variable names that reflect context
- Run `air format .` before committing changes to ensure consistent
  formatting
- Never change deprecated functions

### Documentation

- Use roxygen2 with Markdown syntax for all function documentation
- Keep each sentence on its own line in roxygen2 comments for better
  readability
- Document all arguments and return values
- Document internal functions using devtag (work in progress)
- Link to C documentation using `@cdocs` tag:
  `#' @cdocs igraph_function_name`
- Always run `devtools::document()` after updating documentation

### New functions

All new functions must include:

- Examples
- Tests
- Proper documentation, including arguments and return values
- A concept so that it exists in the pkgdown reference index
- An “experimental” badge via `r lifecycle::badge("experimental")`

## File Structure and Organization

### Test Files

- Test files should align with source files
- `R/name.R` → `tests/testthat/test-name.R`

### Scratch Directory

- `scratch/` is for exploratory R scripts, notes, and temporary files
  not part of the package
- Place temporary or planning markdown files in `scratch/`, not in
  `tests/` or other tracked directories

## Testing

- Add test cases for all new functionality
- Test file naming should mirror source file naming: `R/name.R` →
  `tests/testthat/test-name.R`
- Place new tests near existing tests for the same function in the test
  file
- Add regression tests for bug fixes directly after the last existing
  test for the affected function
- Implement both structured and snapshot tests
- When testing error behavior, prefer snapshot tests
- When testing output-producing functions
  (e.g. [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md)),
  prefer snapshot tests over regex-based assertions
- Run tests frequently during development and at the end:
  `testthat::test_local(reporter = "check")`
- Run `devtools::check()` as a final step to ensure all checks pass
