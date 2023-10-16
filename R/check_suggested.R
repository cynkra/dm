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
check_suggested <- function(packages,
                            use,
                            top_level_fun = NULL
                            ) {
  # If NA, inform that package isn't installed, but only in interactive mode
  if (is.na(use)) {
    use <- is_interactive()
    if (!use) {
      return(FALSE)
    }

    installed <- map_lgl(packages, function(pkg) {
      is_installed(pkg)
    })

    if (any(!installed)) {
      pkgs_not_installed <- packages[!installed]
      message <- "{.fn {top_level_fun}} is improved by the '{.pkg {pkgs_not_installed}}' package. Consider installing them."
      cli::cli_inform(message)
    }

    return(all(installed))
  }

  # If FALSE, hide
  if (!use) {
    return(FALSE)
  }

  # Return early if all packages are installed.
  if (rlang::is_installed(packages)) {
    return(TRUE)
  }

  # Skip if some packages are not installed when testing
  # And say which package was not installed.
  if (is_testing()) {
    installed <- map_lgl(packages, function(pkg) {
      is_installed(pkg)
    })
    pkgs_not_installed <- packages[!installed]
    message <- cli::format_inline("{.fn {top_level_fun}} needs the {.pkg {pkgs_not_installed}} package.")
    testthat::skip(message)
  } else {
    # If in interactive session, a prompt will ask user if they want
    # to install the package.
    # check_installed() uses pak for installation
    # if it's installed on the user system.

    # Which message to display in the prompt (if top_level_fun is mentioned.)
    message <- if (is.null(top_level_fun)) {
      NULL
    } else {
      glue("to use `{top_level_fun}()`.")
    }
    rlang::check_installed(packages, reason = message)
  }

  TRUE
}
