# FIXME: make more robust as we implement all json functions
unjson_nested <- function(data) {
  safe_fromJSON <- function(x) {
    tryCatch(map(x, jsonlite::fromJSON), error = function(e) x)
  }
  mutate(data, across(where(is.character), safe_fromJSON))
}
