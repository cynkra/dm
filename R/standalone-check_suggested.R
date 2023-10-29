# ---
# repo: cynkra/dm
# file: standalone-check_suggested.R
# last-updated: 2023-02-23
# license: https://unlicense.org
# imports: rlang
# ---
#
# This file provides a wrapper around `rlang::check_installed()` that skips tests
# and supports optional usage.
#
# Needs functions from rlang, and purrr or standalone-purrr.R.
#
# ## Changelog
#
# 2023-10-19:
# * Initial

# nocov start

#' Check if suggested package is installed
#'
#' @param packages Vector of package names to check. Can supply a version
#'   between parenthesis. (See examples).
#' @param top_level_fun the name of the top level function called.
#' @param use whether to trigger the check, `NA` means `TRUE` if `is_interactive()`
#'   and `FALSE` otherwise
#' @return whether check was triggered and all packages are installed
#' @noRd
#' @examples
#' check_suggested(c("testthat (>= 3.2.0)", "xxx"), "foo")
check_suggested <- function(packages, top_level_fun, use = TRUE) {
  # If NA, inform that package isn't installed, but only in interactive mode
  only_msg <- is.na(use)
  if (only_msg) {
    use <- is_interactive()
  }

  if (!use) {
    return(FALSE)
  }

  # Check installation status if `use` was not `FALSE`
  installed <- map_lgl(packages, is_installed)

  if (all(installed)) {
    return(TRUE)
  }

  if (only_msg) {
    pkgs_not_installed <- packages[!installed]
    message <- "{.fn {top_level_fun}} is improved by the {.pkg {.val {pkgs_not_installed}}} package{?s}. Consider installing {?it/them}."
    cli::cli_inform(message)

    return(FALSE)
  }

  # Skip if some packages are not installed when testing
  # And say which package was not installed.
  if (identical(Sys.getenv("TESTTHAT"), "true")) {
    pkgs_not_installed <- packages[!installed]
    message <- cli::format_inline("{.fn {top_level_fun}} needs the {.pkg {.val {pkgs_not_installed}}} package{?s}.")
    testthat::skip(message)
  }

  # If in interactive session, a prompt will ask user if they want
  # to install the package.
  # check_installed() uses pak for installation
  # if it's installed on the user system.

  # Which message to display in the prompt
  check_installed(packages, reason = glue("to use `{top_level_fun}()`."))

  # If check_installed() returns, all packages are installed
  TRUE
}

# nocov end
