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
check_suggested <- function(packages, use, top_level_fun = NULL, message = NULL) {
  # If NA, inform that package isn't install, but only in interactive mode
  if (is.na(use)) {
    use <- is_interactive()
    if (!use) {
      return(FALSE)
    }

    installed <- map_lgl(packages, ~ {
      installed <- is_installed(.)
      if (!installed) {
        if (is.null(message)) {
          message <- glue("`{top_level_fun}()` is improved by the '{.}' package. Consider `install.packages(\"{.}\")`.")
        }
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

  # If TRUE, fail if package is not installed
  for (pkg in packages) {
    if (!is_installed(pkg)) {
      if (is.null(message)) {
        message <- glue("`{top_level_fun}()` needs the '{pkg}' package. Do you need `install.packages(\"{pkg}\")` ?")
      }
      abort(message)
    }
  }
  TRUE
}
