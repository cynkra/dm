#' @export
cdm_copy_to <- function(dest, dm, set_key_constraints = TRUE, table_names = NULL, temporary = TRUE, ...) {
# for now focusing on MSSQL
# we expect the src (dest) to already point to the correct schema
# we want to
#   1. change `dm$src` to `dest`
#   2. copy the tables to `dest`
#   3. implement the key situation within our `dm` on the DB


if (is_null(table_names)) {
  list_of_unique_names <- tibble(table_names = src_tbls(dm),
                                 unique_names = map_chr(src_tbls(dm), unique_db_table_name)
  )
} else {
  stopifnot(length(table_names) == length(src_tbls(dm)))
  list_of_unique_names <- tibble(table_names = src_tbls(dm),
                                 unique_names = table_names
  )
}
name_vector <- pull(list_of_unique_names, unique_names)

new_tables <- copy_list_of_tables_to(
  dest,
  list_of_tables = cdm_get_tables(dm),
  name_vector = name_vector,
  temporary = temporary,
  ...)


if (set_key_constraints) {
  tables_w_pk <- cdm_get_all_pks(dm)
  pk_info <- tables_w_pk %>%
    left_join(list_of_unique_names, by = c("table" = "table_names"))

  fk_info <-
    cdm_get_all_fks(dm) %>%
    left_join(tables_w_pk, by = c("parent_table" = "table")) %>%
    left_join(list_of_unique_names, by = c("child_table" = "table_names")) %>%
    rename(db_child_table = unique_names) %>%
    left_join(list_of_unique_names, by = c("parent_table" = "table_names")) %>%
    rename(db_parent_table = unique_names)

  queries <- create_queries(dest, pk_info, fk_info, temporary)
  walk(queries, ~dbExecute(dest, .))
  }

new_src <- if (is.src(dest)) dest else src_dbi(dest)

invisible(
  new_dm(
    src = new_src,
    tables = new_tables,
    data_model = cdm_get_data_model(dm))
  )
}
