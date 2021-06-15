check_suggested <- function(package, use, message) {
  if (is.na(use)) {
    use <- is_interactive()
    if (use && !is_installed(package)) {
      inform(message)
    }
  }

  if (!use) {
    return(FALSE)
  }

  if (!is_installed(package)) {
    abort(message)
  }
  TRUE
}
