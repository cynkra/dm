new_keys <- function(x) {
  # both c("a", "b") and list("a", "b") is accepted
  if (!is.list(x)) {
    x <- as.list(as.character(x))
  }
  vctrs::new_list_of(x, character(), class = "dm_keys")
}

#' @export
vec_ptype_abbr.dm_keys <- function(x) {
  "keys"
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
