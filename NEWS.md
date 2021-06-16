<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# dm 0.2.2.9001

- Implement `rows_delete()` for databases (#589).
- Fix `rows_truncate()` in interactive mode (#588).


# dm 0.2.2.9000

Internal changes only.

# dm 0.2.2

## Features

- `dm_examine_constraints()`, `dm_rows_insert()` and related, `copy_dm_to()` and `collect.dm()` show progress bars in interactive mode via the progress package. The new `progress = NA` argument controls the behavior (#262, @moodymudskipper).
- `copy_dm_to()` gains a `copy_to` argument to support other ways of copying data to the database (#582).

## Internal

- Always run database tests on sqlite for df source.
- Establish compatibility with testthat > 3.0.2 (#566, @moodymudskipper).


# dm 0.2.1

## Breaking changes

- `dm_get_all_fks()` returns a data frame with a  `parent_key_cols` instead of a `parent_pk_cols` column (introduced in dm 0.2.0), to reflect the fact that a foreign key no longer necessarily points to a primary key (#562).
- `*_pk()` and `*_fk()` functions now verify that the dots are actually empty (#536).
- `dm_get_pk()` is deprecated in favor of `dm_get_all_pks()` (#561).
- `dm_has_fk()` and `dm_get_fk()` are deprecated in favor of `dm_get_all_fks()` (#561).

## Features

- `dm_add_fk()` gains `ref_columns` argument that supports creating foreign keys to non-primary keys (#402).
- `dm_get_all_pks()` gains `table` argument for filtering the returned primary keys (#560).
- `dm_get_all_fks()` gains `parent_table` argument for filtering the returned foreign keys (#560).
- `dm_rm_fk()` gains an optional `ref_columns` argument. This function now supports removal of multiple foreign keys filtered by parent or child table or columns, with a message (#559).
- `dm_rm_pk()` gains `columns` argument and allows filtering by columns and by tables or removing all primary keys. The `rm_referencing_fks` argument has been deprecated in favor of the new `fail_fk` argument (#558).
- `dm_get_all_fks()` has been optimized for speed and no longer sorts the keys (#560).
- dm operations are now slightly faster overall.

## Internal

- The internal data structure for a dm object has changed to accommodate foreign keys to other columns than the primary key. An upgrade message is shown when working with a dm object from an earlier version, e.g. if it was loaded from a cache or an `.rds` file (#402).
- Drop `"dm_v1"` class from dm objects again, this would have made every S3 dispatch more costly. Relying on an internal `"version"` attribute instead (#547).


# dm 0.2.0

## Breaking changes

- Deprecate `dm_get_src()` `tbl.dm()`, `src_tbls.dm()`, `copy_to.dm()`. These functions have better alternatives and use the notion of a "data source" which is being phased out of dplyr (#527).
- `*_pk()` and `*_fk()` functions gain an ellipsis argument that comes before `check`, `force` and `rm_referencing_fks` arguments (#520).

## Features

- `dm_add_pk()` and `dm_add_fk()` support compound keys via the `c()` notation, e.g. `dm_add_pk(dm, table, c(col1, col2))`. `dm_nycflights13()` returns a data model with compound keys by default. Use `compound = FALSE` to return the data model from dm v0.1.13 or earlier (#3).
- `dm_get_all_fks()` includes `parent_pk_cols` column that describes the primary key columns of the parent table (#335).
- `dm_from_src()` supports the `schema` argument also for MariaDB and MySQL databases (#516).
- dm objects now inherit from `"dm_v1"` in addition to `"dm"`, to allow backward-compatible changes of the internal format (#521).
- Use hack to create compound primary keys on the database (#522).
- `dm_examine_constraints()` and other check functions count the number of rows that violate constraints for primary and foreign keys (#335).
- `copy_dm_to(set_key_constraints = FALSE)` downgrades unique indexes to regular indexes (#335).
- `rows_truncate()` implemented for data frames (#335).
- `dm_enum_fk_candidates()` enumerates column in the order they apper in the table (#335).

# dm 0.1.13

## Features

- `dm_draw()` gains `column_types` argument, if `TRUE` the column type is shown for each displayed column (#444, @samssann).
- `copy_dm_to()` gains `schema` argument (#432).
- `dm_from_src()` gains `dbname` argument for MSSQL (#472).

## Bug fixes

- Fix `rows_update()` when multiple columns are updated (#488, @samssann).

## Performance

- `enum_fk_candidates()` now only checks distinct values, this improves performance for large tables. As a consequence, only the number of distinct values is reported for mismatches, not the number of mismatching rows/entries (#494).

## Documentation

- Fix description of filtering behavior in `?dm_zoom_to` (#403).

## Internal

- Move repository to <https://github.com/cynkra/dm> (#500).
- Enable more Postgres tests (#497).
- Test DuckDB on GitHub Actions (#498).


# dm 0.1.12

- `dm_from_src()` gains `dbname` argument for MSSQL (#472).
- Implement `count()` and `tally()` for dplyr 1.0.3 compatibility (#475).
- Use databases.pacha.dev instead of db-edu.pacha.dev (#478, @pachamaltese).


# dm 0.1.10

- Columns with missing values are no longer primary keys (#469).
- Fix `dm_from_src()` for MSSQL when `learn_keys = FALSE` (#427).
- Tests use `expect_snapshot()` everywhere (#456).
- Fix compatibility with testthat 3.0.1 (#457).


# dm 0.1.9

- New `vignette("howto-dm-copy", package = "dm")` and `vignette("howto-dm-rows", package = "dm")` discuss updating data on the database. In part derived from `vignette("howto-dm-db", package = "dm")` (#411, @jawond).
- New `dm_mutate_tbl()` (#448).
- `dm_financial()` falls back to db-edu.pacha.dev if relational.fit.cvut.cz is unavailable (#446, @pachamaltese).
- Use testthat 3e (#455).


# dm 0.1.7

- Bump RMariaDB required version to 1.0.10 to work around timeout with `R CMD check`.
- `dm_from_src()` accepts `schema` argument for MSSQL databases (#367).


# dm 0.1.6

## Breaking changes

- `dm_get_src()` returns `NULL` for local data sources (#394).
- Local target in `copy_dm_to()` gives a deprecation message (#395).

## Features

- `copy_dm_to()` gives a better error message for bad `table_names` (#397).
- `dm` objects with local data sources no longer show the "Table source" part in the output.
- Error messages now refer to "tables", not "elements" (#413).
- New `dm_bind()` for binding two or more 'dm' objects together (#417).

## Bug fixes

- For databases, the underlying SQL table names are quoted early to avoid later SQL syntax errors (#419).
- `dm_financial()` no longer prints message about `learn_keys = FALSE`.
- `dm_rows_update()` and related functions now use the primary keys defined in `x` for establishing matching rows.

## Internal

- Use `withCallingHandlers()` where appropriate (#422).
- Consistent definition of `.dm` and `.zoomed_dm` methods (#300).
- Examples involving `dm_financial()` are not run if connection can't be established (#418).
- Fix database tests on CI (#416).


# dm 0.1.5

## Features

- `dm_paste()` generates self-contained code (#401).
- Errors regarding cycles in the relationship graph now show the shortest cycle (#405).
- Implement `rows_truncate()` for databases.
- `collect()` works on a zoomed dm, with a message.
- The data model is drawn in a more compact way if it comprises of multiple connected components.
- `dm_add_pk(check = TRUE)` gives a better error message.

## Bug fixes

- `rows_insert()` works if column names consist of SQL keywords (#409).
- Cycles in other connected components don't affect filtering in a cycle-free component.
- Avoid `src_sqlite()` in examples (#372).

## Internal

- Testing SQLite, Postgres and SQL Server on GitHub Actions (#408, @pat-s).
- Testing packages with all "Suggests" uninstalled.


# dm 0.1.4

## Features

- New `dm_rows_insert()`, `dm_rows_update()`, `dm_rows_patch()`, `dm_rows_upsert()`, `dm_rows_delete()` and `dm_rows_truncate()`, calling the corresponding `rows_*()` method for every table (#319).

- New `rows_truncate()` (#319).

- Added `rows_insert()` and `rows_update()` methods for SQLite, Postgres, MariaDB and MSSQL (#319).

- Missing arguments now give a better error message (#388).

- Empty `dm` object prints as `dm()` (#386).

- `copy_dm_to()` also accepts a function as the `table_names` argument. The `unique_table_names()` argument is deprecated (#80).

## Documentation

- Add TL;DR to README (#377, @jawond).

- Add content from old README to `howto-dm-theory.Rmd` (#378, @jawond).

## Internal

- Require dplyr >= 1.0.0.

- Use GitHub Actions (#369, @pat-s).


# dm 0.1.3

- Avoid `src_sqlite()` in vignettes (#372).
- Rename vignettes (#349).
- Rename error class `"dm_error_tables_not_neighbours"` to `"dm_error_tables_not_neighbors"`.
- Shortened README and intro article (#192, @jawond).
- Better testing for MSSQL (#339).
- Fix compatibility with dplyr 1.0.0.


# dm 0.1.2

## Features

- `dm_from_src()` now works for databases other than Postgres and MSSQL (#288), gives a warning if tables cannot be accessed with `table_name = NULL` (#348), and gains `learn_keys` argument to control querying of primary and foreign keys from the database (#340).
- `dm_examine_constraints()` now prints a different message if a dm has no constraints defined.
- Disambiguation message now only lists column names for easier copy-pasting.
- New methods for `"zoomed_dm"`: `head()`, `tail()`, `pull()`, `group_data()`, `group_indices()`, `group_vars()`, `group_keys()` and `groups()` (#236, #203).
- `dm_paste()` supports writing colors and the table definition via the new `options` argument. The definition can be written to a file via the new `path` argument. The `select` argument is soft-deprecated (#218, #302).
- `dm_add_tbl()` uses `rlang::list2()` internally, now accepts `:=` to specify table names.
- New `dm_ptype()` (#301).
- New `dm_financial()` and `dm_financial_sqlite()`.
- Printing dm objects from database sources with many tables is now faster (#308, @gadenbuie).
- `check_key()` now also works on a zoomed dm.
- Key columns are always selected in a join operation, with a message (#153).
- Support alpha colors for the table colors (#279).


## Bug fixes

- Fix visualization of column that acts as a foreign key more than once (#37).
- `dm_add_pk()`, `dm_rm_pk()`, `dm_add_fk()` and `dm_rm_fk()` are now stricter when keys exists or when attempting to remove keys that don't exist. A more relaxed mode of operation may be added later (#214).
- `examine_cardinality()`, `dm_examine_constraints()` and `enum_pk_candidates()` now work for columns named `n`.
- `dm_set_key_constraints()` (and by extension `dm_copy_to(set_key_constraints = TRUE)`) now quote identifiers for the SQL that creates foreign keys on the database.
- `collect()` gives a better error message when called on a `"zoomed_dm"` (#294).
- `check_subset()` gives a clean error message if the tables are complex expressions.
- `dm_from_src(schema = "...")` works on Postgres if `search_path` is not set on the connection.
- `compute.zoomed_dm()` no longer throws an error.
- Remove unused DT import (#295).


## Compatibility

- Remove use of deprecated `src_df()` (#336).
- Fix compatibility with dplyr 1.0.0 (#203).


## Documentation

- `dm_draw()` output is shown in examples (#251).
- New article "{dm} and databases" (#309, @jawond).


## Internal

- Testing on local data frames (by default), optionally also SQLite, Postgres, RMariaDB, and SQL Server. Currently requires development versions and various pull requests (#334, #327, #312, #76).
- `dm_nycflights13(subset = TRUE)` memoizes subset and also reduces the size of the `weather` table.
- Expand definitions of deprecated functions (#204).


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
- `str()` shows simplified views (#123).
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
