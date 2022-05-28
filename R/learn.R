#' Create data model from database constraints
#'
#' @description If there are any permament tables on a DB, a new [`dm`] object can be created that contains those tables,
#' along with their primary and foreign key constraints.
#'
#' Currently this only works with MSSQL and Postgres databases.
#'
#' The default database schema will be used; it is currently not possible to parametrize the funcion with a specific database schema.
#'
#' @param dest A `src`-object on a DB or a connection to a DB.
#'
#' @family DB interaction functions
#'
#' @return A [`dm`] object with the tables from the DB and the respective key relations.
#'
#' @noRd
#' @examples
#' if (FALSE) {
#'   src_sqlite <- dplyr::src_sqlite(":memory:", create = TRUE)
#'   iris_key <- mutate(iris, key = row_number())
#'
#'   # setting key constraints currently doesn't work on
#'   # SQLite but this would be the code to set the PK
#'   # constraint on the DB
#'   iris_dm <- copy_dm_to(
#'     src_sqlite,
#'     dm(iris = iris_key),
#'     set_key_constraints = TRUE
#'   )
#'
#'   # and this would be the code to learn
#'   # the `dm` from the SQLite DB
#'   iris_dm_learned <- dm_learn_from_db(src_sqlite)
#' }
dm_learn_from_db <- function(dest, dbname = NA, ...) {
  # assuming that we will not try to learn from (globally) temporary tables, which do not appear in sys.table
  con <- con_from_src_or_con(dest)
  src <- src_from_src_or_con(dest)

  if (is.null(con)) {
    return()
  }

  if (!is_mssql(con)) {
    return(dm_learn_from_db_legacy(con, dbname, ...))
  }

  dm_learn_from_db_meta(con, catalog = dbname, ...)
}

dm_learn_from_db_meta <- function(con, catalog = NULL, schema = NULL, name_format = "{table}") {
  info <- dm_meta(con, catalog = catalog, schema = schema)

  df_info <-
    info %>%
    dm_select_tbl(-schemata) %>%
    collect()

  dm_name <-
    df_info$tables %>%
    select(catalog = table_catalog, schema = table_schema, table = table_name) %>%
    mutate(name = glue(!!name_format)) %>%
    pull() %>%
    unclass() %>%
    vec_as_names(repair = "unique")

  from <-
    df_info$tables %>%
    select(catalog = table_catalog, schema = table_schema, table = table_name) %>%
    pmap_chr(~ DBI::dbQuoteIdentifier(con, DBI::Id(...)))

  df_key_info <-
    df_info %>%
    dm_zoom_to(tables) %>%
    mutate(dm_name = !!dm_name, from = !!from) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(columns) %>%
    arrange(ordinal_position) %>%
    select(-ordinal_position) %>%
    left_join(tables) %>%
    dm_update_zoomed() %>%
    dm_select_tbl(constraint_column_usage, key_column_usage, columns)

  table_info <-
    df_key_info %>%
    dm_zoom_to(columns) %>%
    group_by(dm_name, from) %>%
    summarize(vars = list(column_name)) %>%
    ungroup() %>%
    pull_tbl()

  tables <- map2(table_info$from, table_info$vars, ~ tbl(con, dbplyr::ident_q(.x), vars = .y))
  names(tables) <- table_info$dm_name

  pks_df <-
    df_key_info %>%
    dm_zoom_to(key_column_usage) %>%
    anti_join(constraint_column_usage) %>%
    arrange(ordinal_position) %>%
    dm_update_zoomed() %>%
    dm_squash_to_tbl(key_column_usage) %>%
    select(constraint_catalog, constraint_schema, constraint_name, dm_name, column_name) %>%
    group_by(constraint_catalog, constraint_schema, constraint_name, dm_name) %>%
    summarize(pks = list(tibble(column = list(column_name)))) %>%
    ungroup() %>%
    select(table = dm_name, pks)

  fks_df <-
    df_key_info %>%
    dm_zoom_to(key_column_usage) %>%
    left_join(columns, select = c(column_name, dm_name, table_catalog, table_schema, table_name)) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(constraint_column_usage) %>%
    left_join(columns, select = c(column_name, dm_name, table_catalog, table_schema, table_name)) %>%
    dm_update_zoomed() %>%
    dm_select_tbl(-columns) %>%
    dm_rename(constraint_column_usage, constraint_column_usage.table_catalog = table_catalog) %>%
    dm_rename(constraint_column_usage, constraint_column_usage.table_schema = table_schema) %>%
    dm_rename(constraint_column_usage, constraint_column_usage.table_name = table_name) %>%
    dm_rename(constraint_column_usage, constraint_column_usage.column_name = column_name) %>%
    dm_rename(constraint_column_usage, constraint_column_usage.dm_name = dm_name) %>%
    dm_rename(key_column_usage, key_column_usage.table_catalog = table_catalog) %>%
    dm_rename(key_column_usage, key_column_usage.table_schema = table_schema) %>%
    dm_rename(key_column_usage, key_column_usage.table_name = table_name) %>%
    dm_rename(key_column_usage, key_column_usage.column_name = column_name) %>%
    dm_rename(key_column_usage, key_column_usage.dm_name = dm_name) %>%
    dm_flatten_to_tbl(constraint_column_usage) %>%
    select(
      constraint_catalog,
      constraint_schema,
      constraint_name,
      ordinal_position,
      ref_table = constraint_column_usage.dm_name,
      ref_column = constraint_column_usage.column_name,
      table = key_column_usage.dm_name,
      column = key_column_usage.column_name,
    ) %>%
    arrange(
      constraint_catalog,
      constraint_schema,
      constraint_name,
      ordinal_position,
    ) %>%
    select(-ordinal_position) %>%
    # FIXME: Where to learn this in INFORMATION_SCHEMA?
    group_by(
      constraint_catalog,
      constraint_schema,
      constraint_name,
      ref_table,
    ) %>%
    summarize(fks = list(tibble(
      ref_column = list(ref_column),
      table = if (length(table) > 0) table[[1]] else NA_character_,
      column = list(column),
      on_delete = "no_action"
    ))) %>%
    ungroup() %>%
    select(-(1:3)) %>%
    group_by(table = ref_table) %>%
    summarize(fks = list(bind_rows(fks))) %>%
    ungroup()

  new_dm2(tables, pks_df, fks_df)
}

dm_learn_from_db_legacy <- function(con, dbname, ...) {
  sql <- db_learn_query(con, dbname = dbname, ...)
  if (is.null(sql)) {
    return()
  }

  overview <-
    dbGetQuery(con, sql) %>%
    as_tibble()

  if (nrow(overview) == 0) {
    return()
  }

  table_names <-
    overview %>%
    arrange(table) %>%
    distinct(schema, table) %>%
    transmute(
      name = table,
      value = schema_if(schema = schema, table = table, con = con, dbname = dbname)
    ) %>%
    deframe()

  # FIXME: Use tbl_sql(vars = ...)
  tables <- map(table_names, ~ tbl(con, dbplyr::ident_q(.x)))

  data_model <- get_datamodel_from_overview(overview)

  legacy_new_dm(tables, data_model)
}

schema_if <- function(schema, table, con, dbname = NULL) {
  table_sql <- DBI::dbQuoteIdentifier(con, table)
  if (is_null(dbname) || is.na(dbname) || dbname == "") {
    if_else(
      are_na(schema),
      table_sql,
      # need 'coalesce()' cause in case 'schema' is NA, 'if_else()' also tests
      # the FALSE option (to see if same class) and then 'dbQuoteIdentifier()' throws an error
      SQL(paste0(DBI::dbQuoteIdentifier(con, coalesce(schema, "")), ".", table_sql))
    )
  } else {
    # 'schema_if()' only used internally (can e.g. be set to default schema beforehand)
    # so IMHO we don't need a formal 'dm_error' here
    if (anyNA(schema)) abort("`schema` must be given if `dbname` is not NULL`.")
    SQL(paste0(DBI::dbQuoteIdentifier(con, dbname), ".", DBI::dbQuoteIdentifier(con, schema), ".", table_sql))
  }
}

db_learn_query <- function(dest, dbname, ...) {
  if (is_postgres(dest)) {
    return(postgres_learn_query(dest, ...))
  }
}

postgres_learn_query <- function(con, schema = "public", table_type = "BASE TABLE") {
  sprintf(
    "SELECT
    t.table_schema as schema,
    t.table_name as table,
    c.column_name as column,
    case when pk.column_name is null then 0 else 1 end as key,
    fk.ref,
    fk.ref_col,
    case c.is_nullable when 'YES' then 0 else 1 end as mandatory,
    c.data_type as type,
    c.ordinal_position as column_order

    from
    information_schema.columns c
    inner join information_schema.tables t on
    t.table_name = c.table_name
    and t.table_schema = c.table_schema
    and t.table_catalog = c.table_catalog

    left join  -- primary keys
    ( SELECT DISTINCT
      tc.constraint_name, tc.table_name, tc.table_schema, tc.table_catalog, kcu.column_name
      FROM
      information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu ON
      tc.constraint_name = kcu.constraint_name
      WHERE constraint_type = 'PRIMARY KEY'
    ) pk on
    pk.table_name = c.table_name
    and pk.column_name = c.column_name
    and pk.table_schema = c.table_schema
    and pk.table_catalog = c.table_catalog

    left join  -- foreign keys
    ( SELECT DISTINCT
      tc.constraint_name, kcu.table_name, kcu.table_schema, kcu.table_catalog, kcu.column_name,
      ccu.table_name as ref,
      ccu.column_name as ref_col
      FROM
      information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu ON
      tc.constraint_name = kcu.constraint_name
      JOIN information_schema.constraint_column_usage AS ccu ON
      ccu.constraint_name = tc.constraint_name
      WHERE tc.constraint_type = 'FOREIGN KEY'
    ) fk on
    fk.table_name = c.table_name
    and fk.table_schema = c.table_schema
    and fk.table_catalog = c.table_catalog
    and fk.column_name = c.column_name

    where
    c.table_schema = %s
    and t.table_type = %s",
    dbQuoteString(con, schema),
    dbQuoteString(con, table_type)
  )
}

# FIXME: only needed for `dm_learn_from_db()` <- needs to be implemented in a different manner
legacy_new_dm <- function(tables = NULL, data_model = NULL) {
  if (is_null(tables) && is_null(data_model)) {
    return(empty_dm())
  }

  if (!all_same_source(tables)) abort_not_same_src()
  stopifnot(is.data_model(data_model))

  columns <- as_tibble(data_model$columns)

  data_model_tables <- data_model$tables

  stopifnot(all(names(tables) %in% data_model_tables$table))
  stopifnot(all(data_model_tables$table %in% names(tables)))

  pks <-
    columns %>%
    select(column, table, key) %>%
    filter(key > 0) %>%
    select(-key)

  if (is.null(data_model$references) || nrow(data_model$references) == 0) {
    fks <- tibble(
      table = character(),
      column = character(),
      ref = character(),
      ref_column = character(),
      on_delete = character()
    )
  } else {
    fks <-
      data_model$references %>%
      transmute(table, column, ref, ref_column = ref_col, on_delete = "no_action") %>%
      as_tibble()
  }

  # Legacy
  data <- unname(tables[data_model_tables$table])

  table <- data_model_tables$table
  segment <- data_model_tables$segment
  # would be logical NA otherwise, but if set, it is class `character`
  display <- as.character(data_model_tables$display)
  zoom <- new_zoom()
  col_tracker_zoom <- new_col_tracker_zoom()

  pks <-
    pks %>%
    # Legacy compatibility
    mutate(column = as.list(column, list())) %>%
    nest_compat(pks = -table)

  pks <-
    tibble(
      table = setdiff(table, pks$table),
      pks = list_of(new_pk())
    ) %>%
    vec_rbind(pks)

  # Legacy compatibility
  fks$column <- as.list(fks$column)
  fks$ref_column <- as.list(fks$ref_column)

  fks <-
    fks %>%
    nest_compat(fks = -ref) %>%
    rename(table = ref)

  fks <-
    tibble(
      table = setdiff(table, fks$table),
      fks = list_of(new_fk())
    ) %>%
    vec_rbind(fks)

  # there are no filters at this stage
  filters <-
    tibble(
      table = table,
      filters = list_of(new_filter())
    )

  def <-
    tibble(table, data, segment, display) %>%
    left_join(pks, by = "table") %>%
    left_join(fks, by = "table") %>%
    left_join(filters, by = "table") %>%
    left_join(zoom, by = "table") %>%
    left_join(col_tracker_zoom, by = "table")

  new_dm3(def)
}

nest_compat <- function(.data, ...) {
  # `...` has to be name-variable pair (see `?nest()`) of length 1
  quos <- enquos(...)
  stopifnot(length(quos) == 1)
  new_col <- names(quos)
  if (nrow(.data) == 0) {
    remove <- eval_select_indices(quo(c(...)), colnames(.data))
    keep <- setdiff(seq_along(.data), remove)

    nest <- new_list_of(list(), ptype = .data %>% select(!!!remove))

    .data %>%
      select(!!!keep) %>%
      mutate(!!new_col := !!nest)
  } else {
    .data %>%
      nest(...) %>%
      mutate_at(vars(!!!new_col), as_list_of)
  }
}
