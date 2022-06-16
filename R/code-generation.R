dm_f_list <- function(f_list = list()) {
  structure(f_list, class = c("dm_f_list", class(f_list)))
}

add_call <- function(f_list, fn_call) {
  fn <- function(.) NULL
  body(fn) <- enexpr(fn_call)
  dm_f_list(append(f_list, fn))
}

#' @export
print.dm_f_list <- function(x, ...) {
  show_dm_f_list(x)
}

show_dm_f_list <- function(x) {
  if (is_empty(x)) {
    invisible(x)
  } else {
    purrr::map_chr(x, ~ body(.) %>% call_to_char()) %>%
      paste0("  ", ., collapse = " %>%\n") %>%
      cat()
    invisible(x)
  }
}

call_to_char <- function(body) {
  deparse(body) %>%
    paste0(collapse = "") %>%
    gsub("\\s+", " ", .)
}
