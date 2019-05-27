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
