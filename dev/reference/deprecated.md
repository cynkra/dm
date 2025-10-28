# Deprecated functions

These functions are deprecated in favor of better alternatives. Most
functions with the `cdm_` prefix have an identical alternative with a
`dm_` prefix.

`sql_schema_*()` functions have been replaced with the corresponding
`db_schema_*()` functions.

`dm_join_to_tbl()` is deprecated in favor of
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md).

`dm_is_referenced()` is soft-deprecated, use the information returned
from
[`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
instead.

`dm_get_referencing_tables()` is soft-deprecated, use the information
returned from
[`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
instead.

`validate_dm()` has been replaced by
[`dm_validate()`](https://dm.cynkra.com/dev/reference/dm_validate.md)
for consistency.

`dm_add_tbl` is deprecated as of dm 1.0.0, because the same
functionality is offered by
[`dm()`](https://dm.cynkra.com/dev/reference/dm.md) with
`.name_repair = "unique"`.

`dm_bind()` is deprecated as of dm 1.0.0, because the same functionality
is offered by [`dm()`](https://dm.cynkra.com/dev/reference/dm.md).

`dm_squash_to_tbl()` is deprecated as of dm 1.0.0, because the same
functionality is offered by
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md)
with `.recursive = TRUE`.

`rows_truncate()` is deprecated as of dm 1.0.0, because it's a DDL
operation and requires different permissions than the
[`dplyr::rows_*()`](https://dplyr.tidyverse.org/reference/rows.html)
functions.

## Usage

``` r
sql_schema_create(dest, schema, ...)

sql_schema_drop(dest, schema, force = FALSE, ...)

sql_schema_exists(dest, schema, ...)

sql_schema_list(dest, include_default = TRUE, ...)

dm_apply_filters(dm)

dm_apply_filters_to_tbl(dm, table)

dm_get_filters(dm)

dm_join_to_tbl(dm, table_1, table_2, join = left_join)

dm_is_referenced(dm, table)

dm_get_referencing_tables(dm, table)

validate_dm(x)

check_if_subset(t1, c1, t2, c2)

check_cardinality(parent_table, pk_column, child_table, fk_column)

cdm_get_src(x)

cdm_get_con(x)

cdm_get_tables(x)

cdm_get_filter(x)

cdm_add_tbl(dm, ..., repair = "unique", quiet = FALSE)

cdm_rm_tbl(dm, ...)

cdm_copy_to(
  dest,
  dm,
  ...,
  types = NULL,
  overwrite = NULL,
  indexes = NULL,
  unique_indexes = NULL,
  set_key_constraints = TRUE,
  unique_table_names = FALSE,
  table_names = NULL,
  temporary = TRUE
)

cdm_disambiguate_cols(dm, sep = ".", quiet = FALSE)

cdm_draw(
  dm,
  rankdir = "LR",
  col_attr = "column",
  view_type = "keys_only",
  columnArrows = TRUE,
  graph_attrs = "",
  node_attrs = "",
  edge_attrs = "",
  focus = NULL,
  graph_name = "Data Model"
)

cdm_set_colors(dm, ...)

cdm_get_colors(dm)

cdm_get_available_colors()

cdm_filter(dm, table, ...)

cdm_nrow(dm)

cdm_flatten_to_tbl(dm, start, ..., join = left_join)

cdm_squash_to_tbl(dm, start, ..., join = left_join)

cdm_join_to_tbl(dm, table_1, table_2, join = left_join)

cdm_apply_filters(dm)

cdm_apply_filters_to_tbl(dm, table)

cdm_add_pk(dm, table, column, check = FALSE, force = FALSE)

cdm_add_fk(dm, table, column, ref_table, check = FALSE)

cdm_has_fk(dm, table, ref_table)

cdm_get_fk(dm, table, ref_table)

cdm_get_all_fks(dm)

cdm_rm_fk(dm, table, columns, ref_table)

cdm_enum_fk_candidates(dm, table, ref_table)

cdm_is_referenced(dm, table)

cdm_get_referencing_tables(dm, table)

cdm_learn_from_db(dest)

cdm_check_constraints(dm)

cdm_nycflights13(cycle = FALSE, color = TRUE, subset = TRUE)

cdm_paste(dm, select = FALSE, tab_width = 2)

cdm_has_pk(dm, table)

cdm_get_pk(dm, table)

cdm_get_all_pks(dm)

cdm_rm_pk(dm, table, rm_referencing_fks = FALSE)

cdm_enum_pk_candidates(dm, table)

cdm_select_tbl(dm, ...)

cdm_rename_tbl(dm, ...)

cdm_select(dm, table, ...)

cdm_rename(dm, table, ...)

cdm_zoom_to_tbl(dm, table)

cdm_insert_zoomed_tbl(
  dm,
  new_tbl_name = NULL,
  repair = "unique",
  quiet = FALSE
)

cdm_update_zoomed_tbl(dm)

cdm_zoom_out(dm)

dm_rm_tbl(dm, ...)

dm_add_tbl(dm, ..., repair = "unique", quiet = FALSE)

dm_bind(..., repair = "check_unique", quiet = FALSE)

dm_squash_to_tbl(dm, start, ..., join = left_join)

rows_truncate(x, ..., in_place = FALSE)

sql_rows_truncate(x, ...)

dm_rows_truncate(x, y, ..., in_place = NULL, progress = NA)
```

## Arguments

- ...:

  These dots are for future extensions and must be empty.

- force:

  Boolean, if `FALSE` (default), an error will be thrown if there is
  already a primary key set for this table. If `TRUE`, a potential old
  `pk` is deleted before setting a new one.

- dm:

  A [`dm`](https://dm.cynkra.com/dev/reference/dm.md) object.

- table:

  A table in the `dm`.

- table_1:

  One of the tables involved in the join.

- table_2:

  The second table of the join.

- join:

  The type of join to be performed, see
  [`dplyr::join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).

- x:

  An object.

- check:

  Boolean, if `TRUE`, a check is made if the combination of columns is a
  unique key of the table.

- columns:

  Table columns, unquoted. To define a compound key, use
  `c(col1, col2)`.
