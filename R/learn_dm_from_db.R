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

#' @export
cdm_learn_from_postgres <- function(con) {
  # assuming we do not try to learn from temporary tables (which do not appear in sys.table (at least not the globally temporary ones))
  overview <-
    dbGetQuery(con, postgres_learn_query()) %>%
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

postgres_learn_query <- function() {
  "select
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
  and t.table_catalog = c.table_catalog
  and t.table_schema = c.table_schema

  left join  -- primary keys
  ( SELECT
    tc.constraint_name, tc.table_name, kcu.column_name
    FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu ON
    tc.constraint_name = kcu.constraint_name
    WHERE constraint_type = 'PRIMARY KEY'
  ) pk on
  pk.table_name = c.table_name
  and pk.column_name = c.column_name

  left join  -- foreign keys
  ( SELECT
    tc.constraint_name, kcu.table_name, kcu.column_name,
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
  and fk.column_name = c.column_name

  where
  c.table_schema = 'public'
  and t.table_type = 'BASE TABLE'"
}
