register_if_dbplyr_hasnt <- function(...) {
  dbplyr_ns <- asNamespace("dbplyr")

  # Register our method implementations only if dbplyr doesn't provide them
  methods <- enquos(..., .named = TRUE)
  dbplyr_methods <- mget(names(methods), dbplyr_ns, mode = "function", ifnotfound = list(NULL))
  methods <- methods[map_lgl(dbplyr_methods, is.null)]

  if (is_empty(methods)) {
    return()
  }

  methods <- map(methods, eval_tidy)
  classes <- sub("^[^.]*.", "", names(methods))
  fun <- sub("[.].*$", "", names(methods)[[1]])

  map2(classes, methods, s3_register, generic = paste0("dm::", fun))
  invisible()
}
