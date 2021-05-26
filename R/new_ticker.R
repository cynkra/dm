new_ticker <- function(label, n, progress = NA) {
  # if progress bar should'nt be shown, return identity
  # message or fail depending on `progress`

  if (is.na(progress)) {
    progress <- is_interactive()
    if (progress && !is_installed("progress")) {
      inform("The 'progress' package must be installed in order to display progress bars.")
      return(identity)
    }
  }

  if (!progress) return(identity)

  if (!requireNamespace("progress")) {
    stop("The 'progress' package must be installed in order to display progress bars.")
  }

  # pb to be updated by reference by output function
  pb <- progress::progress_bar$new(
    format = sprintf(
      "  %s [:bar] :percent in :elapsed",
      label),
    total = n, clear = FALSE, width = 60)
  # output a function that curries f to tick, updating pb
  function(f) {
    f <- purrr::as_mapper(f)
    function(...) {
      pb$tick()
      f(...)
    }
  }
}
