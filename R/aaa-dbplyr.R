# nocov start
replace_if_dbplyr_has <- function(fun) {
  if (!requireNamespace("dbplyr", quietly = TRUE)) {
    return()
  }

  dbplyr_ns <- asNamespace("dbplyr")

  fun <- as_string(ensym(fun))
  value <- mget(fun, dbplyr_ns, mode = "function", ifnotfound = list(NULL))[[1]]
  if (!is.null(value)) {
    assign(fun, value, inherits = TRUE)
    "dbplyr"
  } else {
    "dm"
  }
}

register_if_dbplyr_hasnt <- function(...) {
  methods <- enquos(..., .named = TRUE)
  if (requireNamespace("dbplyr", quietly = TRUE)) {
    dbplyr_ns <- asNamespace("dbplyr")

    # Register our method implementations only if dbplyr doesn't provide them
    dbplyr_methods <- mget(names(methods), dbplyr_ns, mode = "function", ifnotfound = list(NULL))

    methods <- methods[map_lgl(dbplyr_methods, is.null)]

    if (is_empty(methods)) {
      return()
    }
  }

  methods <- map(methods, eval_tidy)
  classes <- sub("^[^.]*.", "", names(methods))
  fun <- sub("[.].*$", "", names(methods)[[1]])

  map2(classes, methods, s3_register, generic = paste0("dm::", fun))
  invisible()
}
# nocov end
