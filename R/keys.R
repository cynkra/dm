new_keys <- function(x = list()) {
  # both c("a", "b") and list("a", "b") is accepted
  if (is.character(x)) {
    x <- as.list(x)
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
