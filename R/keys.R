new_keys <- function(x = list()) {
  # both c("a", "b") and list("a", "b") is accepted
  if (!is.list(x)) {
    x <- as.list(as.character(x))
  }
  new_list_of(x, character(), class = "dm_keys")
}

#' @export
vec_ptype2.dm_keys.dm_keys <- function(x, y, ...) new_keys()

#' @export
vec_cast.dm_keys.dm_keys <- function(x, to, ...) x

#' @export
vec_ptype_abbr.dm_keys <- function(x, ..., prefix_named, suffix_shape) {
  "keys"
}

#' @export
vec_proxy_compare.dm_keys <- function(x, ...) {
  # Not called: https://github.com/r-lib/vctrs/issues/1373
  x_raw <- vec_data(x)

  if (length(x_raw) > 0) {
    # First figure out the maximum length
    n <- max(lengths(x_raw))

    # Then expand all vectors to this length by filling in with zeros
    full <- map(x_raw, function(x) c(x, rep("", n - length(x))))
  } else {
    full <- list()
  }

  # Then turn into a data frame
  as.data.frame(do.call(rbind, full))
}

pillar_shaft.dm_keys <- function(x, ...) {
  x <- map_chr(x, commas, max_commas = 3)
  pillar::pillar_shaft(x)
}
on_load({
  s3_register("pillar::pillar_shaft", "dm_keys", pillar_shaft.dm_keys)
})

#' @export
format.dm_keys <- function(x, ...) {
  map_chr(x, commas, max_commas = Inf)
}

get_key_cols <- function(x) {
  stopifnot(length(x) == 1)
  x[[1]]
}
