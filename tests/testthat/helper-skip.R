skip_if_error <- function(expr) {
  tryCatch(
    force(expr),
    error = function(e) {
      skip(e$message)
    }
  )
}
