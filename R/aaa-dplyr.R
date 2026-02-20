# nocov start
replace_if_dplyr_has <- function(fun) {
  dplyr_ns <- asNamespace("dplyr")

  fun <- as_string(ensym(fun))
  value <- mget(fun, dplyr_ns, mode = "function", ifnotfound = list(NULL))[[1]]
  if (!is.null(value)) {
    assign(fun, value, inherits = TRUE)
    "dplyr"
  } else {
    "dm"
  }
}

register_if_dplyr_hasnt <- function(...) {
  dplyr_ns <- asNamespace("dplyr")

  # Register our method implementations only if dplyr doesn't provide them
  methods <- enquos(..., .named = TRUE)
  dplyr_methods <- mget(names(methods), dplyr_ns, mode = "function", ifnotfound = list(NULL))
  methods <- methods[map_lgl(dplyr_methods, is.null)]

  if (is_empty(methods)) {
    return()
  }

  methods <- map(methods, eval_tidy)
  classes <- sub("^[^.]*.", "", names(methods))
  fun <- sub("[.].*$", "", names(methods)[[1]])

  map2(classes, methods, s3_register, generic = paste0("dm::", fun))
  invisible()
}
# nocov end
