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
                            top_level_fun = NULL,
                            version = NULL) {
  # If NA, inform that package isn't installed, but only in interactive mode
  if (is.na(use)) {
    use <- is_interactive()
    if (!use) {
      return(FALSE)
    }

    installed <- map_lgl(packages, function(pkg) {
      installed <- is_installed(pkg, version = version)
      if (!installed) {
        # FIXME: Mention version
        message <- glue("`{top_level_fun}()` is improved by the '{pkg}' package. Consider `install.packages(\"{pkg}\")`.")
        inform(message)
      }
      installed
    })
    return(all(installed))
  }

  # If FALSE, hide
  if (!use) {
    return(FALSE)
  }

  # Return early if all packages are installed.
  if (rlang::is_installed(packages, version = version)) {
    return(TRUE)
  }

  # Skip if some packages are not installed when testing
  # And say which package was not installed.
  if (is_testing()) {
    for (pkg in packages) {
      if (!is_installed(pkg)) {
        message <- glue("`{top_level_fun}()` needs the '{pkg}' package.")
        testthat::skip(message)
      }
    }

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
