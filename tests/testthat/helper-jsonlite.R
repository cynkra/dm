to_snapshot_json <- function(x) {
  print(jsonlite::toJSON(x, pretty = TRUE))
}
