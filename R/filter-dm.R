#' @export
cdm_filter <- function(dm, table, ...) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  orig_tbl <- tbl(dm, table_name)

  if (!cdm_has_pk(dm, !!table_name)) {
    abort(paste0(
      "Table '", table_name, "' needs primary key for the filtering to work. ",
      "Please set one using cdm_add_pk()."))
  }

  # get remote tibble of pk-values after filtering
  pk_name_orig <- cdm_get_pk(dm, !!table_name)
  filtered_tbl_pk_obj <- filter(orig_tbl, ...) %>%
    select(!!pk_name_orig) %>%
    compute( unique_indexes = pk_name_orig)

  if (pull(count(filtered_tbl_pk_obj)) == pull(count(orig_tbl))) return(dm) # early return if no filtering was done

  by = pk_name_orig

  # filter original table by performing join with own pk-values
  filtered_tbl <- left_join(
    filtered_tbl_pk_obj,
    orig_tbl,
    by = by
    )

  join_list <- calculate_join_list(dm, table_name)

  filtered_dm <- cdm_update_table(dm, table_name, filtered_tbl)

  perform_joins(filtered_dm, join_list)
}
