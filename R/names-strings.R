get_names <- function(...) {
  rlang::enexprs(...)
}

get_strings <- function(...) {
  unname(purrr::map_chr(get_names(...), rlang::as_string))
}
