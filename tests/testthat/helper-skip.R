skip_if_error <- function(expr) {
  tryCatch(
    force(expr),
    error = function(e) {
      skip(e$message)
    }
  )
}

skip_if_remote_src <- function(src) {
  if (inherits(src, "src_dbi")) skip("this test works only locally")
}

skip_if_local_src <- function(src) {
  if (inherits(src, "src_local")) skip("this test works only on a DB")
}
