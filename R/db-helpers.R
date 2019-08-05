unique_db_table_name <- local({
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

create_queries <- function(
                           dest,
                           pk_information,
                           fk_information) {
  if (!is_null(pk_information)) {
    q_not_nullable <- queries_not_nullable(dest, pk_information)
    q_set_pk_cols <- queries_set_pk_cols(dest, pk_information)
  } else {
    q_not_nullable <- ""
    q_set_pk_cols <- ""
  }

  if (!is_null(fk_information)) {
    q_adapt_fk_col_classes <- queries_adapt_fk_col_classes(dest, fk_information)
    q_set_fk_relations <- queries_set_fk_relations(dest, fk_information)
  } else {
    q_adapt_fk_col_classes <- ""
    q_set_fk_relations <- ""
  }

  queries <- c(q_not_nullable, q_set_pk_cols, q_adapt_fk_col_classes, q_set_fk_relations)
  queries[queries != ""]
}

queries_not_nullable <- function(dest, pk_information) {
  db_tables <- pk_information$remote_name
  cols_to_set_not_null <- pk_information$pk_col
  cols_classes <- pk_information$pk_class
  cols_db_classes <- class_to_db_class(dest, cols_classes)

  if (is_mssql(dest)) {
    pmap_chr(
      list(
        db_tables,
        cols_to_set_not_null,
        cols_db_classes
      ),
      ~ glue("ALTER TABLE {..1} ALTER COLUMN {..2} {..3} NOT NULL")
    )
  } else if (is_postgres(dest)) {
    pmap_chr(
      list(
        db_tables,
        cols_to_set_not_null,
        cols_db_classes
      ),
      ~ glue("ALTER TABLE {..1} ALTER COLUMN {..2} TYPE {..3}, ALTER COLUMN {..2} SET NOT NULL")
    )
  } else {
    return("")
  }
}

queries_set_pk_cols <- function(dest, pk_information) {
  db_tables <- pk_information$remote_name
  cols_to_set_as_pk <- pk_information$pk_col
  if (is_mssql(dest) || is_postgres(dest)) {
    map2_chr(
      db_tables,
      cols_to_set_as_pk,
      ~ glue("ALTER TABLE {.x} ADD CONSTRAINT pk_{.x} PRIMARY KEY ({.y})")
    )
  } else {
    return("")
  }
}

queries_adapt_fk_col_classes <- function(dest, fk_information) {
  db_child_tables <- fk_information$db_child_table
  cols_to_adapt <- fk_information$child_fk_col
  child_col_classes <- fk_information$col_class
  cols_db_classes <- class_to_db_class(dest, child_col_classes)
  if (is_mssql(dest)) {
    pmap_chr(
      list(
        db_child_tables,
        cols_to_adapt,
        cols_db_classes
      ),
      ~ glue("ALTER TABLE {..1} ALTER COLUMN {..2} {..3}")
    )
  } else if (is_postgres(dest)) {
    pmap_chr(
      list(
        db_child_tables,
        cols_to_adapt,
        cols_db_classes
      ),
      ~ glue("ALTER TABLE {..1} ALTER COLUMN {..2} TYPE {..3}")
    )
  } else {
    return("")
  }
}

queries_set_fk_relations <- function(dest, fk_information) {
  db_child_tables <- fk_information$db_child_table
  child_fk_cols <- fk_information$child_fk_col
  db_parent_tables <- fk_information$db_parent_table
  parent_pk_col <- fk_information$pk_col

  if (is_mssql(dest) || is_postgres(dest)) {
    pmap_chr(
      list(
        db_child_tables,
        child_fk_cols,
        db_parent_tables,
        parent_pk_col
      ),
      ~ glue("ALTER TABLE {..1} ADD FOREIGN KEY ({..2}) REFERENCES {..3}({..4}) ON DELETE CASCADE ON UPDATE CASCADE")
    )
  } else {
    return("")
  }
}

class_to_db_class <- function(dest, class_vector) {
  if (is_mssql(dest) || is_postgres(dest)) {
    case_when(
      class_vector == "character" ~ "VARCHAR(100)",
      class_vector == "integer" ~ "INT",
      TRUE ~ class_vector
    )
  } else {
    return(class_vector)
  }
}

get_db_table_names <- function(dm) {
  if (!is_src_db(dm)) {
    return(tibble(table_name = src_tbls(dm), remote_name = src_tbls(dm)))
  }
  tibble(
    table_name = src_tbls(dm),
    remote_name = map_chr(cdm_get_tables(dm), list("ops", "x"))
  )
}

is_src_db <- function(dm) {
  inherits(cdm_get_src(dm), "src_sql")
}

is_mssql <- function(dest) {
  inherits(dest, "Microsoft SQL Server") ||
    inherits(dest, "src_Microsoft SQL Server")
}

is_postgres <- function(dest) {
  inherits(dest, "src_PostgreSQLConnection") ||
    inherits(dest, "PostgreSQLConnection") ||
    inherits(dest, "PqConnection")
}

src_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest else dbplyr::src_dbi(dest)
}

con_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest$con else dest
}
