new_ticker <- function(label, n, progress = NA) {
  suggested <- check_suggested("progress",
    message = "The 'progress' package must be installed in order to display progress bars.",
    use = progress)
  if(!suggested) return(identity)

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
