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

# Internal copy helper functions
build_copy_data <- nse_function(c(dm, dest, unique_table_names), ~ {
  source <- cdm_get_tables(dm)

  if (unique_table_names) {
    dest_names <- map_chr(names(source), unique_db_table_name)
  } else {
    dest_names <- names(source)
  }

  copy_data_base <-
    source %>%
    as.list() %>%
    enframe(name = "source_name", value = "df") %>%
    mutate(name = !!dest_names)

  if (is_db(dest)) {
    dest_con <- con_from_src_or_con(dest)

    pks <-
      cdm_get_all_pks(dm) %>%
      transmute(source_name = table, column = pk_col, pk = TRUE)

    # Need to supply NOT NULL modifiers for primary keys
    # because they are difficult to add to MSSQL after the fact
    copy_data <-
      copy_data_base %>%
      mutate(column = map(df, colnames)) %>%
      mutate(type = map(df, ~ map_chr(., ~ DBI::dbDataType(dest_con, .)))) %>%
      select(-df) %>%
      unnest() %>%
      left_join(pks, by = c("source_name", "column")) %>%
      mutate(full_type = paste0(type, if_else(pk, " NOT NULL", "", ""))) %>%
      group_by(source_name, name) %>%
      summarize(types = list(deframe(tibble(column, full_type)))) %>%
      inner_join(copy_data_base, ., by = c("source_name", "name"))
  } else {
    copy_data <-
      copy_data_base
  }

  copy_data
})

# Not exported, to give us flexibility to change easily
copy_list_of_tables_to <- function(dest, copy_data,
                                   ..., overwrite = FALSE, df = NULL, name = NULL, types = NULL) {

  tables <- pmap(copy_data, copy_to, dest = dest, overwrite = overwrite, ...)
  set_names(tables, copy_data$source_name)
}

create_queries <- function(
                           dest,
                           pk_information,
                           fk_information) {
  if (!is_null(pk_information)) {
    q_set_pk_cols <- queries_set_pk_cols(dest, pk_information)
  } else {
    q_set_pk_cols <- ""
  }

  if (!is_null(fk_information)) {
    q_set_fk_relations <- queries_set_fk_relations(dest, fk_information)
  } else {
    q_set_fk_relations <- ""
  }

  queries <- c(q_set_pk_cols, q_set_fk_relations)
  queries[queries != ""]
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

is_db <- function(x) {
  inherits(x, "src_sql")
}

is_src_db <- function(dm) {
  is_db(cdm_get_src(dm))
}

is_mssql <- function(dest) {
  inherits(dest, "Microsoft SQL Server") ||
    inherits(dest, "src_Microsoft SQL Server")
}

is_postgres <- function(dest) {
  inherits(dest, "src_PostgreSQLConnection") ||
    inherits(dest, "src_PqConnection") ||
    inherits(dest, "PostgreSQLConnection") ||
    inherits(dest, "PqConnection")
}

src_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest else dbplyr::src_dbi(dest)
}

con_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest$con else dest
}
