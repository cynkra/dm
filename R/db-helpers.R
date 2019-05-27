unique_table_name <- local({
  i <- 0

  function(table_name) {
    i <<- i + 1
    glue("{table_name}_", systime_convenient(), "_", as.character(i))
  }
})

systime_convenient <- function() {
  str_replace_all(as.character(Sys.time()), ":", "_") %>%
    str_replace_all("-", "_") %>%
    str_replace(" ", "_")
}

# FIXME: should this be exported?
copy_list_of_tables_to <- function(src, list_of_tables,
                                   name_vector = names(list_of_tables),
                                   overwrite = FALSE, ...) {
  map2(list_of_tables, name_vector, copy_to, dest = src, overwrite = overwrite, ...)
}
