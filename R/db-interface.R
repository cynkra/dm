#' @export
cdm_copy_to <- function(dest, dm, set_key_constraints = TRUE, temporary = TRUE, ...) {
# for now focusing on MSSQL
# we expect the src (dest) to already point to the correct schema
# we want to
#   1. change `dm$src` to `dest`
#   2. copy the tables to `dest`
#   3. implement the key situation within our `dm` on the DB
pk_info <- cdm_get_all_pks(dm)
pk_tables <- pk_info %>% pull(table)
pk_cols <- pk_info %>% pull(pk_col)

fk_info <- cdm_get_all_fks(dm)
fk_child_tbls <- fk_info %>% pull(child_table)
fk_child_cols <- fk_info %>% pull(child_fk_col)
fk_parent_tbls <- fk_info %>% pull(parent_table)

list_of_unique_names <- tibble(table_names = src_tbls(dm),
                               unique_names = map_chr(src_tbls(dm), unique_table_name)
                               )

new_tables <- copy_list_of_tables_to(
  dest,
  list_of_tables = cdm_get_tables(dm),
  name_vector = pull(list_of_unique_names, unique_names),
  temporary = temporary,
  ...)

pk_plus_unique <- list_of_unique_names %>% left_join(pk_info, by = c("table_names" = "table"))

if (set_key_constraints) {
  if (temporary) { # on MSSQL
    queries_not_null <- map2_chr(
      pk_plus_unique$unique_names,
      pk_plus_unique$pk_col,
      ~ glue("ALTER TABLE ##{.x} ALTER COLUMN {.y} INT NOT NULL"))
  } else {
    queries_not_null <- map2_chr(
      pk_plus_unique$unique_names,
      pk_plus_unique$pk_col,
      ~ glue("ALTER TABLE {.x} ALTER COLUMN {.y} INT NOT NULL"))
  }
  walk(queries, ~dbExecute(dest, .))

}






# dbExecute(con, "ALTER TABLE t1 ALTER COLUMN a INT NOT NULL;") # this works
# dbExecute(con, "ALTER TABLE t1 ADD CONSTRAINT pk_t1 PRIMARY KEY (a)")
# dbExecute(con, "ALTER TABLE t2 ADD FOREIGN KEY (d) REFERENCES t1(a) ON DELETE CASCADE ON UPDATE CASCADE")




# ALTER TABLE {table_name} ADD CONSTRAINT PK_{table_name}_{col_name} PRIMARY KEY CLUSTERED (col_name);
# DBI::dbExecute()
# DBI::dbSendQuery("CREATE SCHEMA {schema_name};")

invisible(
  new_dm(
    src = dest,
    tables = new_tables,
    data_model = cdm_get_data_model(dm))
  )
}
