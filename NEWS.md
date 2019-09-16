# dm 0.0.2.9000

- `cdm_flatten_to_tbl()` disambiguates only the necessary columns.
- When flattening, the column name of the LHS (child) table is used (#52).
- Fix formatting in `enum_pk_candidates()` for character data.
- `cdm_add_pk()` and `cdm_add_fk()` no longer check data integrity by default.
- Explicitly checking that the `join` argument is a function, to avoid surprises when the caller passes data.
- `cdm_copy_to()` works correctly with filtered `dm` objects.
- `cdm_apply_filters()` actually resets the filter conditions.
- A more detailed README file and a vignette for filtering (#29, @cutterkom).
- `cdm_draw()` no longer supports the `table_names` argument, use `cdm_select_tbl()`.
- Copying a `dm` to a database now creates indexes for all primary and foreign keys.


# dm 0.0.2

## Breaking changes

- Requires tidyr >= 1.0.0.
- `cdm_nrow()` returns named list (#49).
- Remove `cdm_semi_join()`.
- Remove `cdm_find_conn_tbls()` and the `all_connected` argument to `cdm_select()` (#35).
- Unexport `cdm_set_key_constraints()`.
- Rename `cdm_select()` to `cdm_select_tbl()`, now uses {tidyselect}.
- `cdm_nycflights13()` now has `cycle = FALSE` as default.
- Rename `cdm_check_for_*()` to `cdm_enum_*()`.

## Performance

- `cdm_filter()` only records the filtering operation, the filter is applied only when querying a table via `tbl()` or when calling `compute()` or the new `cdm_apply_filters()` (#32).

## New functions

- New `cdm_flatten_to_tbl()` flattens a `dm` to a wide table with starting from a specified table (#13). Rename `cdm_join_tbl()` to `cdm_join_to_tbl()`.
- New `cdm_disambiguate_cols()` (#40).
- New `cdm_rename()` (#41) and `cdm_select()` (#50) for renaming and selecting columns of `dm` tables.
- New `length.dm()` and `length<-.dm()` (#53).
- `$`, `[[`, `[`, `names()`, `str()` and `length()` now implemented for dm objects (read-only).
- New `enum_pk_candidates()`.

## Minor changes

- `browse_docs()` opens the pkgdown website (#36).
- `as_dm()` now also accepts a list of remote tables (#30).
- Use {tidyselect} syntax for `cdm_rename_tbl()` and `cdm_select_tbl()` (#14).
- The tibbles returned by `cdm_enum_fk_candidates()` and `cdm_enum_pk_candidates()` contain a `why` column that explains the reasons for rejection in a human-readable form (#12).
- Improve compatibility with RPostgres.
- `create_graph_from_dm()` no longer fails in the presence of cycles (#10).
- Only suggest {RSQLite}.
- `cdm_filter()` no longer requires a primary key.
- `decompose_table()` adds the new column in the table to the end.
- `tbl()` now fails if the table is not part of the data model.

## Documentation

- Add setup article (#7).

## Internal

- Using simpler internal data structure to store primary and foreign key relations (#26).
- New `nse_function()` replaces `h()` for marking functions as NSE to avoid R CMD check warnings.
- Simplified internal data structure so that creation of new operations that update a dm becomes easier.
- When copying a dm to a database, `NOT NULL` constraints are set at creation of the table. This removes the necessity to store column types.
- Using {RPostgres} instead of {RPostgreSQL} for testing.


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
