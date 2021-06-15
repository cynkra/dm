#' Check if suggested package is installed
#'
#' @param packages vector of package names to check
#' @param use whether to trigger the check, if `NA` the check is triggered only
#'   if `is_interactive()` is `TRUE`
#' @param top_level_fun the name of the top level function called, not used if
#'   `message` is provided
#' @param message optional custom message, by default the message follows a template
#'
#' @noRd
check_suggested <- function(packages, use, top_level_fun = NULL, message = NULL) {
  if (is.na(use)) {
    use <- is_interactive()
    for (pkg in packages) {
      if (use && !is_installed(pkg)) {
        if (is.null(message)) {
          message <- glue("`{top_level_fun}()` is improved by the '{pkg}' package. Consider `install.packages(\"{pkg}\")`.")
        }
        inform(message)
      }
    }
  }

  if (!use) {
    return(FALSE)
  }

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
