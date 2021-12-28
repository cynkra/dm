# Registered in .onLoad()
compare_proxy.dm <- function(x, path = NULL, ...) {
  list(
    object =
      x %>%
        dm_get_def() %>%
        mutate(., data = transpose(select(., -table))) %>%
        select(table, data) %>%
        deframe() %>%
        map(as.list) %>%
        map(~ {
          .x$pks <- as.list(.x$pks)
          fk_data <-
            .x$fks %>%
            select(-table) %>%
            transpose()
          .x$fks <- set_names(fk_data, .x$fks$table)
          .x
        }),
    path = path
  )
}
