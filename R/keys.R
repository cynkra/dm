new_keys <- function(x = list()) {
  # both c("a", "b") and list("a", "b") is accepted
  if (!is.list(x)) {
    x <- as.list(as.character(x))
  }
  vctrs::new_list_of(x, character(), class = "dm_keys")
}

#' @export
vec_ptype2.dm_keys.dm_keys <- function(x, y, ...) new_keys()

#' @export
vec_cast.dm_keys.dm_keys <- function(x, to, ...) x

#' @export
vec_ptype_abbr.dm_keys <- function(x) {
  "keys"
}

#' @export
vec_proxy_compare.dm_keys <- function(x, ...) {
  # Not called: https://github.com/r-lib/vctrs/issues/1373
  x_raw <- vec_data(x)

  # First figure out the maximum length
  n <- max(vapply(x_raw, length, integer(1)))

  # Then expand all vectors to this length by filling in with zeros
  full <- lapply(x_raw, function(x) c(x, rep("", n - length(x))))

  # Then turn into a data frame
  as.data.frame(do.call(rbind, full))
}

#' @export
pillar_shaft.dm_keys <- function(x) {
  x <- map_chr(x, commas, max_commas = 3)
  pillar::pillar_shaft(x)
}

#' @export
format.dm_keys <- function(x, ...) {
  map_chr(x, commas, max_commas = Inf)
}
