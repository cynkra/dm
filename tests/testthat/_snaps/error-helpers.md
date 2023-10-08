# output

    Code
      abort_key_set_force_false("pk_table")
    Condition
      Error in `abort_key_set_force_false()`:
      ! Table `pk_table` already has a primary key. Use `force = TRUE` to change the existing primary key.
    Code
      abort_not_unique_key("Christmas", "Rudolph")
    Condition
      Error in `abort_not_unique_key()`:
      ! (`Rudolph`) not a unique key of `Christmas`.
    Code
      abort_not_unique_key("Christmas", c("elves", "Rudolph", "mulled_wine"))
    Condition
      Error in `abort_not_unique_key()`:
      ! (`elves`, `Rudolph`, `mulled_wine`) not a unique key of `Christmas`.
    Code
      abort_table_not_in_dm("laziness", "hard_work")
    Condition
      Error in `abort_table_not_in_dm()`:
      ! Table `laziness` not in `dm` object. Available table names: `hard_work`.
    Code
      abort_not_subset_of("playing", "game", "hunting", "game")
    Condition
      Error in `abort_not_subset_of()`:
      ! Column (`game`) of table `playing` contains values (see examples above) that are not present in column (`game`) of table `hunting`.
    Code
      abort_sets_not_equal(c("A problem occurred.",
        "And another, even worse problem, occurred shortly after."))
    Condition
      Error in `abort_sets_not_equal()`:
      ! A problem occurred.
        And another, even worse problem, occurred shortly after.
    Code
      abort_not_bijective("child_table_name", "fk_col_name")
    Condition
      Error in `abort_not_bijective()`:
      ! 1..1 cardinality (bijectivity) is not given: Column (`fk_col_name`) in table `child_table_name` contains duplicate values.
    Code
      abort_not_injective("child_table_name", "fk_col_name")
    Condition
      Error in `abort_not_injective()`:
      ! 0..1 cardinality (injectivity from child table to parent table) is not given: Column (`fk_col_name`) in table `child_table_name` contains duplicate values.
    Code
      abort_ref_tbl_has_no_pk("parent_table")
    Condition
      Error in `abort_ref_tbl_has_no_pk()`:
      ! ref_table `parent_table` needs a primary key first. Use `dm_enum_pk_candidates()` to find appropriate columns and `dm_add_pk()` to define a primary key.
    Code
      abort_is_not_fkc()
    Condition
      Error in `abort_is_not_fkc()`:
      ! No foreign keys to remove.
    Code
      abort_rm_fk_col_missing()
    Condition
      Error in `abort_rm_fk_col_missing()`:
      ! Parameter `columns` has to be set. Pass `NULL` for removing all references.
    Code
      abort_last_col_missing()
    Condition
      Error in `abort_last_col_missing()`:
      ! The last color can't be missing.
    Code
      abort_no_cycles(create_graph_from_dm(dm_for_filter_w_cycle()))
    Condition
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW(1, 'A'),
          ROW(2, 'B'),
          ROW(3, 'C'),
          ROW(4, 'D'),
          ROW(5, 'E...' at line 11 [1064]
    Code
      abort_tables_not_reachable_from_start()
    Condition
      Error in `abort_tables_not_reachable_from_start()`:
      ! All selected tables must be reachable from `.start`.
    Code
      abort_dupl_new_id_col_name("tibbletable")
    Condition
      Error in `abort_dupl_new_id_col_name()`:
      ! `new_id_column` can't have an identical name as one of the columns of `tibbletable`.
    Code
      abort_no_overwrite()
    Condition
      Error in `abort_no_overwrite()`:
      ! `eval()` does not support the `overwrite` argument.
    Code
      abort_no_types()
    Condition
      Error in `abort_no_types()`:
      ! `copy_dm_to()` does not support the `types` argument.
    Code
      abort_no_indexes()
    Condition
      Error in `abort_no_indexes()`:
      ! `copy_dm_to()` does not support the `indexes` argument.
    Code
      abort_no_unique_indexes()
    Condition
      Error in `abort_no_unique_indexes()`:
      ! `copy_dm_to()` does not support the `unique_indexes` argument.
    Code
      abort_pk_not_defined()
    Condition
      Error in `abort_pk_not_defined()`:
      ! No primary keys to remove.
    Code
      abort_fk_exists("child", c("child_1", "child_2"), "parent")
    Condition
      Error in `abort_fk_exists()`:
      ! (`child_1`, `child_2`) is already a foreign key of table `child` into table `parent`.
    Code
      abort_first_rm_fks("parent", c("child_1", "child_2"))
    Condition
      Error in `abort_first_rm_fks()`:
      ! There are foreign keys pointing from table(s) `child_1`, `child_2` to table `parent`. First remove those, or set `fail_fk = FALSE`.
    Code
      abort_update_not_supported()
    Condition
      Error in `abort_update_not_supported()`:
      ! Updating `dm` objects not supported.
    Code
      abort_only_possible_wo_filters("find_wisdom")
    Condition
      Error in `abort_only_possible_wo_filters()`:
      ! You can't call `find_wisdom()` on a `dm` with filter conditions. Consider using `dm_apply_filters()` first.
    Code
      abort_tables_not_neighbors("subjects", "king")
    Condition
      Error in `abort_tables_not_neighbors()`:
      ! Tables `subjects` and `king` are not directly linked by a foreign key relation.
    Code
      abort_only_parents()
    Condition
      Error in `abort_only_parents()`:
      ! When using `dm_join_to_tbl()` or `dm_flatten_to_tbl()` all join partners of table `.start` have to be its direct neighbors. For 'flattening' with `left_join()`, `inner_join()` or `full_join()` use `dm_flatten_to_tbl(.recursive = TRUE)` as an alternative.
    Code
      abort_not_same_src()
    Condition
      Error in `abort_not_same_src()`:
      ! Not all tables in the object share the same `src`.
    Code
      abort_what_a_weird_object("monster")
    Condition
      Error in `abort_what_a_weird_object()`:
      ! Don't know how to determine table source for object of class `monster`.
    Code
      abort_not_same_src()
    Condition
      Error in `abort_not_same_src()`:
      ! Not all tables in the object share the same `src`.
    Code
      abort_squash_limited()
    Condition
      Error in `abort_squash_limited()`:
      ! `dm_flatten_to_tbl(.recursive = TRUE)` only supports join methods `left_join`, `inner_join`, `full_join`.
    Code
      abort_apply_filters_first("join_tightly")
    Condition
      Error in `abort_apply_filters_first()`:
      ! `dm_..._to_tbl()` with join method `join_tightly` generally wouldn't produce the correct result when filters are set. Please consider calling `dm_apply_filters()` first.
    Code
      abort_no_flatten_with_nest_join()
    Condition
      Error in `abort_no_flatten_with_nest_join()`:
      ! `dm_..._to_tbl()` can't be called with `join = nest_join`, see the help pages for these functions. Consider `join = left_join`.
    Code
      abort_is_not_dm("blob")
    Condition
      Error in `abort_is_not_dm()`:
      ! Required class `dm` but instead is `blob`.
    Code
      abort_con_only_for_dbi()
    Condition
      Error in `abort_con_only_for_dbi()`:
      ! A local `dm` doesn't have a DB connection.
    Code
      abort_only_possible_wo_zoom("dm_zoom_to")
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_zoom_to()` on a `dm_zoomed`. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.
    Code
      abort_only_possible_w_zoom("dm_update_zoomed")
    Condition
      Error in `abort_only_possible_w_zoom()`:
      ! You can't call `dm_update_zoomed()` on an unzoomed `dm`. Consider using `dm_zoom_to()` first.
    Code
      abort_learn_keys(error_cnd(message = "some reason"))
    Condition
      Error in `abort_learn_keys()`:
      ! Failed to learn keys from database.
      i Use `learn_keys = FALSE` to work around, or `dm:::dm_meta()` to debug.
      Caused by error:
      ! some reason
    Code
      abort_tbl_access("accessdenied")
    Condition
      Error in `dm_abort()`:
      ! Table(s) `accessdenied` cannot be accessed.
      i Use `tbl(src, ...)` to troubleshoot.
    Code
      abort_need_unique_names("clone")
    Condition
      Error in `abort_need_unique_names()`:
      ! Each new table needs to have a unique name. Duplicate new name(s): `clone`.
    Code
      abort_fk_not_tracked("hook", "eye")
    Condition
      Error in `abort_fk_not_tracked()`:
      ! The foreign key that existed between the originally zoomed table `hook` and `eye` got lost in transformations. Please explicitly provide the `by` argument.
    Code
      abort_dm_invalid("it's ugly.")
    Condition
      Error in `abort_dm_invalid()`:
      ! This `dm` is invalid, reason: it's ugly.
    Code
      abort_no_table_provided()
    Condition
      Error in `abort_no_table_provided()`:
      ! Argument `table` for `pull_tbl.dm()` missing.
    Code
      abort_table_not_zoomed("blur", c("focus_1", "focus_2"))
    Condition
      Error in `abort_table_not_zoomed()`:
      ! In `pull_tbl.dm_zoomed`: Table `blur` not zoomed, zoomed tables: `focus_1`, `focus_2`.
    Code
      abort_not_pulling_multiple_zoomed()
    Condition
      Error in `abort_not_pulling_multiple_zoomed()`:
      ! If more than 1 zoomed table is available you need to specify argument `table` in `pull_tbl.dm_zoomed()`.
    Code
      abort_cols_not_avail(c("pink5", "elephant"))
    Condition
      Error in `abort_cols_not_avail()`:
      ! The color(s) `pink5`, `elephant` are not available. Call `dm_get_available_colors()` for possible color names or use hex color codes.
    Code
      abort_only_named_args("give_names", "frobnicability")
    Condition
      Error in `abort_only_named_args()`:
      ! All `...` arguments to function `give_names()` must be named. The names represent frobnicability.
    Code
      abort_wrong_syntax_set_cols()
    Condition
      Error in `abort_wrong_syntax_set_cols()`:
      ! You seem to be using outdated syntax for `dm_set_colors()`, type `?dm_set_colors()` for examples.
    Code
      abort_pk_not_tracked("house", "house_number")
    Condition
      Error in `abort_pk_not_tracked()`:
      ! The primary key column(s) `house_number` of the originally zoomed table `house` got lost in transformations. Therefore it is not possible to use `nest.dm_zoomed()`.
    Code
      abort_only_for_local_src(mtcars)
    Condition
      Error in `abort_only_for_local_src()`:
      ! `nest_join.dm_zoomed()` works only for a local `src`, not on a database with `src`-class: `data.frame`.
    Code
      abort_parameter_not_correct_class("number", correct_class = "numeric", class = "logical")
    Condition
      Error in `abort_parameter_not_correct_class()`:
      ! Parameter `number` needs to be of class `numeric` but is of class `logical`.
    Code
      abort_parameter_not_correct_length("length_1_parameter", 1, letters[1:26])
    Condition
      Error in `abort_parameter_not_correct_length()`:
      ! Parameter `length_1_parameter` needs to be of length `1` but is of length 26 (`a`, `b`, `c`, `d`, `e`, ... (26 total)).
    Code
      warn_if_arg_not("NULL", c("MSSQL", "Postgres"), arg_name = "dbms_dependent_arg")
    Condition
      Warning:
      Argument `dbms_dependent_arg` ignored: currently only supported for MSSQL and Postgres.
    Output
      NULL
    Code
      abort_no_schemas_supported("FantasticDatabaseManagementSystem",
        "hyperconnection")
    Condition
      Error in `abort_no_schemas_supported()`:
      ! The concept of schemas is not supported for DBMS `FantasticDatabaseManagementSystem`.
    Code
      abort_no_schemas_supported(con = 1)
    Condition
      Error in `abort_no_schemas_supported()`:
      ! Currently schemas are not supported for a connection of class `numeric`.
    Code
      abort_no_schemas_supported()
    Condition
      Error in `abort_no_schemas_supported()`:
      ! Schemas are not available locally.
    Code
      abort_temporary_not_in_schema()
    Condition
      Error in `abort_temporary_not_in_schema()`:
      ! If argument `temporary = TRUE`, argument `schema` has to be `NULL`.
    Code
      abort_one_of_schema_table_names()
    Condition
      Error in `abort_one_of_schema_table_names()`:
      ! Only one of the arguments `schema` and `table_names` can be different from `NULL`.

