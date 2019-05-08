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

  # get local tibble of pk-values after filtering
  pk_name_orig <- cdm_get_pk(dm, !!table_name)
  filtered_tbl_pk_obj <- filter(orig_tbl, ...) %>%
    select(!!pk_name_orig) %>%
    compute()

  if (nrow(filtered_tbl_pk_obj) == nrow(orig_tbl)) return(dm) # early return if no filtering was done

  by = pk_name_orig

  # filter original table by performing join with own pk-values
  filtered_tbl <- left_join(
    filtered_tbl_pk_obj,
    orig_tbl,
    by = by
    )

  # FIXME: missing:
  #   1. produce ordered list of filtering joins
  #   2. perform joins
  #   (3. adapt the following part of updating the $tables part)

  # update $tables part of `dm`-object
  tables_obj <- cdm_get_tables(dm)
  tables_obj[[table_name]] <- filtered_tbl
  new_dm(
    src = cdm_get_src(dm),
    tables = tables_obj,
    data_model = cdm_get_data_model(dm)
  )
}
