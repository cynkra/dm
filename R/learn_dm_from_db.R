#' @export
cdm_learn_from_mssql <- function(con) {
  # assuming we do not try to learn from temporary tables (which do not appear in sys.table (at least not the globally temporary ones))
  overview <-
    dbGetQuery(con, mssql_learn_query()) %>%
    as_tibble()

  table_names <- distinct(overview, table) %>% pull()

  new_dm(
    src = con,
    tables = map(table_names, ~tbl(con, .)) %>% set_names(table_names),
    data_model = get_datamodel_from_overview(overview))
}

mssql_learn_query <- function() { # taken directly from {datamodelr}
  "select
    tabs.name as [table],
    cols.name as [column],
    isnull(ind_col.column_id, 0) as [key],
    OBJECT_NAME (ref.referenced_object_id) AS ref,
    COL_NAME (ref.referenced_object_id, ref.referenced_column_id) AS ref_col,
    1 - cols.is_nullable as mandatory,
    types.name as [type],
    cols.max_length,
    cols.precision,
    cols.scale
  from
    sys.all_columns cols
    inner join sys.tables tabs on
      cols.object_id = tabs.object_id
    left outer join sys.foreign_key_columns ref on
      ref.parent_object_id = tabs.object_id
      and ref.parent_column_id = cols.column_id
    left outer join sys.indexes ind on
      ind.object_id = tabs.object_id
      and ind.is_primary_key = 1
    left outer join sys.index_columns ind_col on
      ind_col.object_id = ind.object_id
      and ind_col.index_id = ind.index_id
      and ind_col.column_id = cols.column_id
    left outer join sys.systypes [types] on
      types.xusertype = cols.system_type_id
  order by
    tabs.create_date,
    cols.column_id"
}
