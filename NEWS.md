# dm 0.0.0.9010

- Handling `data_model` part more systematically (#49).
- New `cdm_nycflights13()` and `cdm_with()` (!22).
- Classed errors.
- New `copy_to()` to transfer entire data models to another source (#38).


# dm 0.0.0.9009

- New `cdm_semi_join()`, expecting the `filter` as complete reduced table.
- New function `cdm_select()` to focus on part of `dm`-object or chose unconnected tables from it.
- Remove arguments `ref_column` and `set_ref_pk` in function `cdm_add_fk()`.
- Avoid  creating integer64 columns in Postgres.
- New `cdm_nrow()`.
- Fix color order with `dm_set_color()`.


# dm 0.0.0.9008

- Compute joins correctly for arbitrary cycle-free relationships (#16).
- Tweak drawing API: `cdm_draw()`, `cdm_get_colors()`, `cdm_set_colors()` and `cdm_available_colors()` (!8). 
- Print number of rows.


# dm 0.0.0.9007

- New `cdm_filter()`, works only for natural ordering of tables for now (#16).
- New `cdm_join_tbl()` (#19).

# dm 0.0.0.9006

- Functions for drawing a data model and defining colors (!7).
- Track foreign keys (!6).


# dm 0.0.0.9005

- Update documentation, bugfixes.


# dm 0.0.0.9004

- Rename `dm_*` to `cdm_*` (#28).
- Tests are independent of database versions (#26).
- Stub for "Getting started" vignette (#27).


# dm 0.0.0.9003

- Rename `primary_key` to `pk` and `foreign_key` to `fk`.


# dm 0.0.0.9002

- Facilities to manage primary keys in a `dm` object: `dm_add_primary_key()`, `dm_remove_primary_key()`, `dm_check_*()`, `dm_get_primary_key_column_from_table()` (#17).
- Draft for `dm` class with constructor, validator etc., incomplete (#10).


# dm 0.0.0.9001

Initial version.

- `rowSelector()` and `selectable()` modules, with corresponding `...UI()` functions.
- `decompose_table()` to split a table in two.
- `reunite_parent_child_from_list()`, inverse to `decompose_table()`.
- `reunite_parent_child()`, as a shortcut for `reunite_parent_child_from_list()`.
- `check_cardinality_0_1()`, `check_cardinality_0_n()`, `check_cardinality_1_1()` and `check_cardinality_1_n()` to check relationships between tables, powered by `check_if_subset()`, `check_key()` and `check_set_equality()`.
