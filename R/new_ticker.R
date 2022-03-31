new_ticker <- function(label, n, progress = NA, top_level_fun = NULL) {
  suggested <- check_suggested("progress",
    top_level_fun = top_level_fun,
    use = progress
  )
  if (!suggested) return(identity)

  # pb to be updated by reference by output function
  pb <- progress::progress_bar$new(
    format = sprintf(
      "  %s [:bar] :percent in :elapsed",
      label
    ),
    total = n, clear = FALSE
  )
  # output a function that curries f to tick, updating pb
  function(f) {
    f <- purrr::as_mapper(f)
    function(...) {
      pb$tick()
      f(...)
    }
  }
}
