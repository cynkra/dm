
dm_examine_cardinalities <- function(dm) {
  check_not_zoomed(dm)
  dm %>%
    dm_examine_cardinalities_impl() %>%
    new_dm_examine_cardinalities()
}

dm_examine_cardinalities_impl <- function(dm) {
  fks <- dm_get_all_fks_impl(dm) %>%
    select(-on_delete)
  dm_def <- as.list(dm)
  fks_data <- fks %>%
    mutate(
      pt_name = parent_table,
      ct_name = child_table,
      parent_table = dm_def[pt_name],
      child_table = dm_def[ct_name]
    ) %>%
    mutate(
      parent_key_cols = as.list(parent_key_cols),
      child_fk_cols = as.list(child_fk_cols)
    )
  fks %>%
    mutate(
      cardinality = pmap_chr(
        fks_data,
        examine_cardinality_impl
      )
    )
}

new_dm_examine_cardinalities <- function(x) {
  class(x) <- c("dm_examine_cardinalities", class(x))
  x
}

#' @export
print.dm_examine_cardinalities <- function(x, ...) {
  if (nrow(x) == 0) {
    cli::cli_alert_warning("No FKs available in `dm`.")
    return(invisible(x))
  }
  x %>%
    mutate(
      cardinalities =
        pmap_chr(
          x,
          function(parent_table, parent_key_cols, child_table, child_fk_cols, cardinality) {
            paste0(
              "FK: ",
              child_table,
              "$(",
              commas(tick(child_fk_cols)),
              ") -> ",
              parent_table,
              "$(",
              commas(tick(parent_key_cols)),
              "): ",
              cardinality
            )
          }
        )
    ) %>%
    bullets_cardinalities()
}

bullets_cardinalities <- function(x) {
  x <- mutate(
    x,
    col = if_else(grepl("mapping", cardinality), "black", "red")
  ) %>%
    arrange(col)
  walk2(x$cardinalities, x$col, ~ cli::cat_bullet(.x, bullet_col = .y))
  if (sum(x$col == "red") > 0) {
    cli::cli_alert_warning("Not all FK constraints satisfied, call `dm_examine_constraints()` for details.")
  }
  invisible(x)
}
