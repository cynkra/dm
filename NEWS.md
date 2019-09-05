# dm 0.0.1.9002

- `cdm_filter()` only records the filtering operation, the filter is applied only when querying a table via `tbl()` or when calling `compute()` (#32).
- New `str.dm()` .
- Remove `cdm_find_conn_tbls()` and the `all_connected` argument to `cdm_select()` (#35).
- `browse_docs()` opens the pkgdown website (#36).
- `as_dm()` now also accepts a list of remote tables (#30).
- Using simpler internal data structure to store primary and foreign key relations (#26).
- Use {tidyselect} syntax for `cdm_rename_tbl()` and `cdm_select_tbl()` (#14).
- Numeric subsetting in `[` and `[[` now raises a clear error (#18).
- New `nse_function()` replaces `h()` for marking functions as NSE to avoid R CMD check warnings.
- Simplified internal data structure so that creation of new operations that update a dm becomes easier.
- Unexport `cdm_set_key_constraints()`.
- When copying a dm to a database, `NOT NULL` constraints are set at creation of the table.
- The tibbles returned by `cdm_enum_fk_candidates()` and `cdm_enum_pk_candidates()` contain a `why` column that explains the reasons for rejection in a human-readable form (#12).
- Using {RPostgres} instead of {RPostgreSQL} for testing.
- Improve compatibility with RPostgres.


# dm 0.0.1.9001

- Fix corner case for calculating join list: works if table isn't related to other tables.
- `create_graph_from_dm()` no longer fails in the presence of cycles (#10).
- Add setup article (#7).


# dm 0.0.1.9000

- Only suggest {RSQLite}.
- `cdm_filter()` no longer requires a primary key.
- `decompose_table()` adds the new column in the table to the end.
- Rename `cdm_select()` to `cdm_select_tbl()`.
- `cdm_nycflights13()` now has `cycle = FALSE` as default.
- `$`, `[[`, `[`, and `names()` now implemented for dm objects (read-only).
- `tbl()` now fails if the table is not part of the data model.
- `cdm_select()` uses tidyselect.
- New `enum_pk_candidates()`.
- Rename `cdm_check_for_*()` to `cdm_enum_*()`.


# dm 0.0.1

Initial GitHub release.

## Creating `dm` objects and basic functions:

- `dm()`
- `new_dm()`
- `validate_dm()`
- `cdm_get_src()`
- `cdm_get_tables()`
- `cdm_get_data_model()`
- `is_dm()`
- `as_dm()`

## Primary keys

- `cdm_add_pk()`
- `cdm_has_pk()`
- `cdm_get_pk()`
- `cdm_get_all_pks()`
- `cdm_rm_pk()`
- `cdm_check_for_pk_candidates()`

## Foreign keys
  
- `cdm_add_fk()`
- `cdm_has_fk()`
- `cdm_get_fk()`
- `cdm_get_all_fks()`
- `cdm_rm_fk()`
- `cdm_check_for_fk_candidates()`

## Visualization

- `cdm_draw()`
- `cdm_set_colors()`
- `cdm_get_colors()`
- `cdm_get_available_colors()`

## Flattening
  
- `cdm_join_tbl()`

## Filtering

- `cdm_filter()`
- `cdm_semi_join()`
- `cdm_nrow()`

## Interaction with DBs

- `cdm_copy_to()`
- `cdm_set_key_constraints()`
- `cdm_learn_from_db()`

## Utilizing foreign key relations

- `cdm_is_referenced()`
- `cdm_get_referencing_tables()`
- `cdm_select()`
- `cdm_find_conn_tbls()`

## Table surgery

- `decompose_table()`
- `reunite_parent_child()`
- `reunite_parent_child_from_list()`

## Check keys and cardinalities

- `check_key()`
- `check_if_subset()`
- `check_set_equality()`
- `check_cardinality_0_n()`
- `check_cardinality_1_n()`
- `check_cardinality_1_1()`
- `check_cardinality_0_1()`

## Miscellaneous

- `cdm_nycflights13()`
- `cdm_rename_table()`
- `cdm_rename_tables()`
