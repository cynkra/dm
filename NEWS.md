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
