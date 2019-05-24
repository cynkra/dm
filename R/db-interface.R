#' @export
cdm_copy_to <- function(dest, dm, overwrite = TRUE) {
# for now focusing on MSSQL
# we want to
#   1. change `dm$src` to `dest`
#   2. copy the tables to `dest`
#   3. implement the key situation within our `dm` on the DB

new_tables <- copy_list_of_tables_to(dest, list_of_tables = cdm_get_tables(dm), overwrite = overwrite)

invisible(
  new_dm(
    src = dest,
    tables = new_tables,
    data_model = cdm_get_data_model(dm))
  )
}
