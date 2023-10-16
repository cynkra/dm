#' Check if suggested package is installed
#'
#' @param packages vector of package names to check
#' @param use whether to trigger the check, if `NA` the check is triggered only
#'   if `is_interactive()` is `TRUE`
#' @param top_level_fun the name of the top level function called, not used if
#'   `message` is provided
#' @param message optional custom message, by default the message follows a template
#' @return whether check was triggered and all packages are installed
#' @noRd
check_suggested <- function(packages, use, top_level_fun = NULL) {
  # If NA, inform that package isn't installed, but only in interactive mode
  only_msg <- is.na(use)
  if (only_msg) {
    use <- is_interactive()
    if (!use) {
      return(FALSE)
    }
  }

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

  # If FALSE, hide
  if (!use) {
    return(FALSE)
  }

  # Skip if some packages are not installed when testing
  # And say which package was not installed.
  if (is_testing()) {
    pkgs_not_installed <- packages[!installed]
    message <- cli::format_inline("{.fn {top_level_fun}} needs the {.pkg {.val {pkgs_not_installed}}} package{?s}.")
    testthat::skip(message)
  } else {
    # If in interactive session, a prompt will ask user if they want
    # to install the package.
    # check_installed() uses pak for installation
    # if it's installed on the user system.

    # Which message to display in the prompt (if top_level_fun is mentioned.)
    if (is.null(top_level_fun)) {
      message <- NULL
    } else {
      message <- glue("to use `{top_level_fun}()`.")
    }
    rlang::check_installed(packages, reason = message)
  }

  TRUE
}
