dm_f_list <- function(f_list = list()) {
  structure(f_list, class = c("dm_f_list", class(f_list)))
}

add_call <- function(f_list, fn_call) {
  fn <- function(.) NULL
  body(fn) <- fn_call
  dm_f_list(append(f_list, fn))
}

print.dm_f_list <- function(x, ...) {
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

add_foreign_key_code <- function(f_list = dm_f_list(),
                                 table,
                                 columns,
                                 ref_table,
                                 ref_columns = NULL,
                                 ...,
                                 check = FALSE,
                                 on_delete = c("no_action", "cascade")) {
  fn_call <- expr(
    dm_add_fk(
      .,
      table = !!enexpr(table),
      columns = !!enexpr(columns),
      ref_table = !!enexpr(ref_table),
      ref_columns = !!enexpr(ref_columns),
      check = !!check,
      on_delete = !!on_delete
    )
  )
  add_call(f_list, fn_call)
}

rm_foreign_key_code <- function(f_list = dm_f_list(),
                                table,
                                columns,
                                ref_table,
                                ref_columns = NULL) {
  fn_call <- expr(
    dm_rm_fk(
      .,
      table = !!enexpr(table),
      columns = !!enexpr(columns),
      ref_table = !!enexpr(ref_table),
      ref_columns = !!enexpr(ref_columns)
    )
  )
  add_call(f_list, fn_call)
}
