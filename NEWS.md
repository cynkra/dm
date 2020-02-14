# dm 0.1.1

- Implement `format.dm()`.
- Adapt to tidyselect 1.0.0 (#257).
- Zooming and unzooming is now faster if no columns are removed.
- Table names must be unique.
- `dm_examine_constraints()` formats the problems nicely.
- New class for prettier printing of keys (#244).
- Add experimental schema support for `dm_from_src()` for Postgres through the new `schema` and `table_type` arguments (#256).


# dm 0.1.0

- Package is now in the "maturing" lifecycle (#154).
- `filter.zoomed_dm()` no longer sets the filter.
- `examine_()` functions never throw an error (#238).
- API overhaul: `dm_zoom_to()`, `dm_insert_zoomed()`, `dm_update_zoomed()` and `dm_discard_zoomed()`; `check_()` -> `examine_()`; `dm_get_filter()` -> `dm_get_filters()`; `dm_from_src()` + `dm_learn_from_db()` -> `dm_from_src()` (#233).
- New `$.zoomed_dm()`, `[.zoomed_dm()`, `[[.zoomed_dm()`, `length.zoomed_dm()`, `names.zoomed_dm()`, `tbl_vars.zoomed_dm()` (#199, #216).
- New `as.list()` methods (#213).
- Help pages for dplyr methods (#209).
- New migration guide from dm <= 0.0.5 (#234).
- New {tidyselect} interface for setting colors (#162) and support for hex color codes as well as R standard colors.
- Prepare `dm_examine_constraints()` and other key-related functions for compound keys (#239).
- Avoid warnings in `R CMD check` with dev versions of dependencies.
- Improve error messages for missing tables (#220).


# dm 0.0.6

- Change `cdm_` prefix to `dm_`. The old names are still available (#117).
- New `pull_tbl()` extracts a single table from a `dm` (#206).
- New `dm_apply_filters_to_tbl()` that applies filters in related tables to a table, similar to `dm_apply_filters()`; `tbl()`, `$` and `[[` no longer apply filter conditions defined in related tables (#161).
- New `dm_paste()` (#160).
- New `check_cardinality()` returns the nature of the relationship between `parent_table$pk_col` and `child_table$fk_col` (#15).
- New zoom vignette (#171).
- `check_key()` no longer maps empty selection list to all columns.
- `check_key()` supports tidyselect (#188).
- `dm_rm_tbl()` supports tidyselect (#127).
- `decompose_table()` uses tidyselect (#194).
- Implement `copy_to()` for `dm` objects (#129).
- Relax test for cycles in relationship graph (#198).
- Return `ref_table` column in `dm_check_constraints()` (#178).
- `str()` shows simpified views (#123).
- Edits to README (#172, @bbecane).
- Extend `validate_dm()` (#173).
- Fix zooming into table that uses an FK column as primary key (#193).
- Fix corner case in `dm_rm_fk()` (#175).
- More efficient `check_key()` for databases (#208).
- Testing for R >= 3.3 and for debug versions.
- Remove {stringr} dependency (#183).


# dm 0.0.5

## Features

- `cdm_filter()` and `filter.zoomed_dm()` apply the filter instantly, the expression is recorded only for display purposes and for terminating the search for filtered tables in `cdm_apply_filters()`. This now allows using a variety of operations on filtered `dm` objects (#124).
- `dimnames()`, `colnames()`, `dim()`, `distinct()`, `arrange()`, `slice()`, `separate()` and `unite()` implemented for zoomed dm-s (#130).
- Joins on zoomed dm objects now supported (#121). Joins use the same column name disambiguation algorithm as `cdm_flatten_to_tbl()` (#147).
- `slice.zoomed_dm()`: user decides in arg `.keep_pk` if PK column is tracked or not (#152).
- Supported {dplyr} and {tidyr} verbs are reexported.
- `enum_pk_candidates()` works with zoomed dm-s (#156).
- New `enum_fk_candidates()` (#156).
- Add name repair argument for both `cdm_insert_zoomed_tbl()` and `cdm_add_tbl()`, defaulting to renaming of old and new tables when adding tables with duplicate names (#132).
- Redesign constructors and validators: `dm()` is akin to `tibble()`, `dm_from_src()` works like `dm()` did previously, `new_dm()` only accepts a list of tables and no longer validates, `validate_dm()` checks internal consistency (#69).
- `compute.dm()` applies filters and calls `compute()` on all tables (#135).

## Documentation

- New demo.
- Add explanation for empty `dm` (#100).

## Bug fixes

- Avoid asterisk when printing local `zoomed_dm` (#131).
- `cdm_select_tbl()` works again when multiple foreign keys are defined between two tables (#122).


# dm 0.0.4

- Many {dplyr} verbs now work on tables in a `dm`. Zooming to a table vie `cdm_zoom_to_tbl()` creates a zoomed `dm` on which the {dplyr} verbs can be applied. The resulting table can be put back into the `dm` with `cdm_update_zoomed_tbl()` (overwriting the original table) or `cdm_insert_zoomed_tbl()` (creating a new table), respectively (#89).
- `cdm_select_to_tbl()` removes foreign key constraints if the corresponding columns are removed.
- Integrate code from {datamodelr} in this package (@bergant, #111).
- Reorder tables in `"dm"` using `cdm_select_tbl()` (#108).
- More accurate documentation of filtering operation (#98).
- Support empty `dm` objects via `dm()` and `new_dm()` (#96).
- `cdm_flatten_to_tbl()` now flattens all immediate neighbors by default (#95).
- New `cdm_add_tbl()` and `cdm_rm_tbl()` (#90).
- New `cdm_get_con()` (#84).
- A `dm` object is defined using a nested tibble, one row per table (#57).


# dm 0.0.3

- `cdm_enum_pk_candidates()` and `cdm_enum_fk_candidates()` both show candidates first (#85).
- `cdm_flatten_to_tbl()` works only in the immediate neighborhood (#75).
- New `cdm_squash_to_tbl()` implements recursive flattening for left, inner and full join (#75).
- Updated readme and introduction vignette (#72, @cutterkom).
- New `cdm_check_constraints()` to check referential integrity of a `dm` (#56).
- `cdm_copy_to()` gains `table_names` argument (#79).
- `check_key()` now deals correctly with named column lists (#83).
- Improve error message when calling `cdm_add_pk()` with a missing column.


# dm 0.0.2.9003

- Fix `R CMD check`.


# dm 0.0.2.9002

- Use caching to improve loading times.
- Run some tests only for one source (#76).
- `cdm_enum_fk_candidates()` checks for class compatibility implicitly via `left_join()`.
- `cdm_enum_fk_candidates()` contains a more detailed entry in column why if no error & no candidate (percentage of mismatched vals etc.).
- Improve error messages for `cdm_join_to_tbl()` and `cdm_flatten_to_tbl()` in the presence of cycles or disconnected tables (#74).


# dm 0.0.2.9001

- Remove the `src` component from dm (#38).
- Internal: Add function checking if all tables have same src.
- Internal: Add 2 classed errors.
- `cdm_get_src()` for local dm always returns a src based on `.GlobalEnv`.
- `cdm_flatten()` gains `...` argument to specify which tables to include. Currently, all tables must form a connected subtree rooted at `start`. Disambiguation of column names now happens after selecting relevant tables. The resulting SQL query is more efficient for inner and outer joins if filtering is applied. Flattening with a `right_join` with more than two tables is not well-defined and gives an error (#62).
- Add a vignette for joining functions (#60, @cutterkom).
- Shorten message in `cdm_disambiguate_cols()`.


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
