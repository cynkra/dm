skip_if_error <- function(expr) {
  tryCatch(
    force(expr),
    error = function(e) {
      skip(e$message)
    }
  )
}

skip_if_remote_src <- function() {
  # FIXME: PR #313: implement me
}

skip_if_local_src <- function() {
  # FIXME: PR #313: implement me
}
