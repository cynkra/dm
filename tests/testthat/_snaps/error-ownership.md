# dm_add_pk() - abort_key_set_force_false

    Code
      dm_add_pk(d, a, x)
    Condition
      Error in `dm_add_pk()`:
      ! Table a already has a primary key. Use `force = TRUE` to change the existing primary key.

# dm_add_pk() - abort_not_unique_key (via check)

    Code
      dm_add_pk(d, a, x, check = TRUE)
    Condition
      Error in `check_key()`:
      ! (`x`) not a unique key of `a`.

# dm_rm_pk() - abort_pk_not_defined

    Code
      dm_rm_pk(d, a)
    Condition
      Error in `dm_rm_pk()`:
      ! No primary keys to remove.

# dm_add_fk() - abort_ref_tbl_has_no_pk

    Code
      dm_add_fk(d, a, x, ref_table = b)
    Condition
      Error in `dm_add_fk()`:
      ! ref_table b needs a primary key first. Use `dm_enum_pk_candidates()` to find appropriate columns and `dm_add_pk()` to define a primary key.

# dm_add_fk() - abort_fk_exists

    Code
      dm_add_fk(d, a, x, ref_table = b)
    Condition
      Error in `dm_add_fk()`:
      ! (`x`) is already a foreign key of table a into table b.

# dm_add_fk() - abort_not_subset_of (via check)

    Code
      dm_add_fk(d, a, x, ref_table = b, check = TRUE)
    Condition
      Error in `dm_add_fk()`:
      ! Column (`x`) of table a contains values (see examples above) that are not present in column (`x`) of table b.

# dm_rm_fk() - abort_is_not_fkc

    Code
      dm_rm_fk(d, a, x, ref_table = b)
    Condition
      Error in `dm_rm_fk()`:
      ! No foreign keys to remove.

# dm_add_uk() - abort_no_uk_if_pk (PK exists)

    Code
      dm_add_uk(d, a, x)
    Condition
      Error in `dm_add_uk()`:
      ! A PK (`x`) for table a already exists, not adding UK.

# dm_add_uk() - abort_no_uk_if_pk (UK exists)

    Code
      dm_add_uk(d, a, x)
    Condition
      Error in `dm_add_uk()`:
      ! A UK (`x`) for table a already exists, not adding UK.

# dm_rm_uk() - abort_uk_not_defined

    Code
      dm_rm_uk(d, a)
    Condition
      Error in `dm_rm_uk()`:
      ! No unique keys to remove.

# check_key() - abort_not_unique_key

    Code
      check_key(t, x)
    Condition
      Error in `check_key()`:
      ! (`x`) not a unique key of `t`.

# check_cardinality_1_1() - abort_not_bijective

    Code
      check_cardinality_1_1(parent, child, by_position = TRUE)
    Condition
      Error in `check_cardinality_1_1()`:
      ! 1..1 cardinality (bijectivity) is not given: Column (`x`) in table child contains duplicate values.

# check_cardinality_0_1() - abort_not_injective

    Code
      check_cardinality_0_1(parent, child, by_position = TRUE)
    Condition
      Error in `check_cardinality_0_1()`:
      ! 0..1 cardinality (injectivity from child table to parent table) is not given: Column (`x`) in table child contains duplicate values.

# dm_set_colors() - abort_only_named_args

    Code
      dm_set_colors(d, a)
    Condition
      Error in `dm_set_colors()`:
      ! All `...` arguments must be named. The names represent the colors.

# dm_set_colors() - abort_wrong_syntax_set_cols

    Code
      dm_set_colors(d, a = "blue")
    Condition
      Error in `dm_set_colors()`:
      ! You seem to be using outdated syntax for setting colors, type `?dm_set_colors()` for examples.

# dm_set_colors() - abort_cols_not_avail

    Code
      dm_set_colors(d, nonexistent_color_xyz = a)
    Condition
      Error in `dm_set_colors()`:
      ! The color "nonexistent_color_xyz" is not available. Call `dm_get_available_colors()` for possible color names or use hex color codes.

# dm_get_con() - abort_con_only_for_dbi

    Code
      dm_get_con(d)
    Condition
      Error in `dm_get_con()`:
      ! A local <dm> doesn't have a DB connection.

# $<-.dm - abort_update_not_supported

    Code
      d$a <- tibble(x = 2)
    Condition
      Error in `$<-`:
      ! Updating <dm> objects not supported.

# [<-.dm - abort_update_not_supported

    Code
      d[["a"]] <- tibble(x = 2)
    Condition
      Error in `[[<-`:
      ! Updating <dm> objects not supported.

# dm_validate() - abort_is_not_dm

    Code
      dm_validate("not_a_dm")
    Condition
      Error in `dm_validate()`:
      ! Required class <dm> but instead is <character>.

# dm_validate() - abort_dm_invalid

    Code
      dm_validate(bad)
    Condition
      Error in `dm_validate()`:
      ! This <dm> is invalid, reason: A `dm` needs to be a list of one item named `def`.

# dm_zoom_to() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_zoom_to(d, b)
    Condition
      Error in `dm_zoom_to()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_update_zoomed() on unzoomed dm - abort_only_possible_w_zoom

    Code
      dm_update_zoomed(d)
    Condition
      Error in `dm_update_zoomed()`:
      ! Not supported on an unzoomed <dm>. Consider using `dm_zoom_to()` first.

# dm_flatten_to_tbl() with recursive and unsupported join - abort_squash_limited

    Code
      dm_flatten_to_tbl(d, a, .recursive = TRUE, .join = right_join)
    Condition
      Error in `dm_flatten_to_tbl()`:
      ! Recursive flattening only supports `left_join()`, `inner_join()`, or `full_join()`.

# dm_flatten_to_tbl() with nest_join - abort_no_flatten_with_nest_join

    Code
      dm_flatten_to_tbl(d, a, .join = nest_join)
    Condition
      Error in `dm_flatten_to_tbl()`:
      ! `join = nest_join` is not supported. Consider `join = left_join`.

# dm_rename_tbl() - abort_need_unique_names

    Code
      dm_rename_tbl(d, a = b)
    Condition
      Error in `dm_rename_tbl()`:
      ! Each new table needs to have a unique name. Duplicate new name: a.

# decompose_table() - abort_dupl_new_id_col_name

    Code
      decompose_table(t, x, y)
    Condition
      Error in `decompose_table()`:
      ! `new_id_column` can't have an identical name as one of the columns of t.

# dm_paste() - abort_unknown_option

    Code
      dm_paste(d, options = "nonexistent_option")
    Condition
      Error in `dm_paste()`:
      ! Option unknown: "nonexistent_option". Must be one of "all", "tables", "keys", "select", and "color".

# check_set_equality() - abort_sets_not_equal

    Code
      check_set_equality(parent, child, by_position = TRUE)
    Output
      # A tibble: 1 x 1
            x
        <int>
      1     3
    Condition
      Error in `check_set_equality()`:
      ! Column (`x`) of table parent contains values (see examples above) that are not present in column (`x`) of table child.

# dm_draw() - unsupported backend_opts

    Code
      dm_draw(d, backend_opts = list(unsupported_option = TRUE))
    Condition
      Error in `dm_draw()`:
      ! Unsupported `backend_opts` for backend "DiagrammeR": unsupported_option.
      i Supported options are: graph_attrs, node_attrs, edge_attrs, focus, graph_name, column_arrow, and font_size.

# copy_to.dm() - abort_only_data_frames_supported

    Code
      copy_to(d, 42, name = "b")
    Condition
      Error in `copy_to()`:
      ! Only class <data.frame> is supported for argument `df`.

# copy_to.dm() - abort_no_overwrite

    Code
      copy_to(d, tibble(y = 1), name = "b", overwrite = TRUE)
    Condition
      Error in `copy_to()`:
      ! The `overwrite` argument is not supported.

# copy_to.dm() - abort_one_name_for_copy_to

    Code
      copy_to(d, tibble(y = 1), name = c("b", "c"))
    Condition
      Error in `copy_to()`:
      ! Argument `name` must have length 1, not length 2.

# pull_tbl() on dm with table not in dm - abort_table_not_in_dm

    Code
      pull_tbl(d, nonexistent)
    Condition
      Error in `pull_tbl()`:
      ! Table nonexistent not in <dm> object. Available table names: a.

# pull_tbl() on zoomed dm with wrong table - abort_table_not_zoomed

    Code
      pull_tbl(d, b)
    Condition
      Error in `pull_tbl()`:
      ! Table `b` not zoomed, zoomed tables: `a`.

# dm_flatten_to_tbl() with unrelated tables - abort_tables_not_reachable_from_start

    Code
      dm_flatten_to_tbl(d, a, c)
    Condition
      Error in `dm_flatten_to_tbl()`:
      ! All selected tables must be reachable from `.start`.

# dm_flatten_to_tbl() with grandparent - abort_only_parents

    Code
      dm_flatten_to_tbl(d, a, b, c)
    Condition
      Error in `dm_flatten_to_tbl()`:
      ! All join partners of table `.start` must be its direct neighbors. Use `.recursive = TRUE` for recursive flattening.

# dm_flatten_to_tbl() with cycle - abort_no_cycles

    Code
      dm_flatten_to_tbl(dm_for_filter_w_cycle(), tf_5, .recursive = TRUE)
    Condition
      Error in `dm_flatten_to_tbl()`:
      ! Cycles in the relationship graph not yet supported.
      i Shortest cycle: tf_5 -> tf_6 -> tf_7 -> tf_2 -> tf_3 -> tf_4 -> tf_5

# dm_select_tbl() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_select_tbl(d, a)
    Condition
      Error in `dm_select_tbl()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_add_pk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_add_pk(d, b, x)
    Condition
      Error in `dm_add_pk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_add_fk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_add_fk(d, a, x, ref_table = b)
    Condition
      Error in `dm_add_fk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_get_con() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_get_con(d)
    Condition
      Error in `dm_get_con()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_insert_zoomed() on unzoomed dm - abort_only_possible_w_zoom

    Code
      dm_insert_zoomed(d)
    Condition
      Error in `dm_insert_zoomed()`:
      ! Not supported on an unzoomed <dm>. Consider using `dm_zoom_to()` first.

# dm_draw() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_draw(d)
    Condition
      Error in `dm_draw()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_paste() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_paste(d)
    Condition
      Error in `dm_paste()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_flatten() - abort_tables_not_neighbors

    Code
      dm_flatten(d, a, parent_tables = c)
    Condition
      Error in `dm_flatten()`:
      ! All selected tables must be reachable from `table`.

# pull_tbl() - abort_no_table_provided

    Code
      pull_tbl(d, )
    Condition
      Error in `pull_tbl()`:
      ! Argument `table` is missing.

# dm_flatten_to_tbl() - abort_no_flatten_with_nest_join (via dm_join_to_tbl)

    Code
      dm_join_to_tbl(d, a, b, join = nest_join)
    Condition
      Error in `dm_join_to_tbl()`:
      ! `join = nest_join` is not supported. Consider `join = left_join`.

# dm_examine_constraints() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_examine_constraints(d)
    Condition
      Error in `dm_examine_constraints()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_disambiguate_cols() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_disambiguate_cols(d)
    Condition
      Error in `dm_disambiguate_cols()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_rm_pk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_rm_pk(d, a)
    Condition
      Error in `dm_rm_pk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_rm_fk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_rm_fk(d, a, x, ref_table = b)
    Condition
      Error in `dm_rm_fk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_add_uk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_add_uk(d, a, x)
    Condition
      Error in `dm_add_uk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_rm_uk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_rm_uk(d, a)
    Condition
      Error in `dm_rm_uk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_has_pk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_has_pk(d, a)
    Condition
      Error in `dm_has_pk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_get_pk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_get_pk(d, a)
    Condition
      Error in `dm_get_pk()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_get_all_pks() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_get_all_pks(d)
    Condition
      Error in `dm_get_all_pks()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_get_all_fks() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_get_all_fks(d)
    Condition
      Error in `dm_get_all_fks()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_get_all_uks() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_get_all_uks(d)
    Condition
      Error in `dm_get_all_uks()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_enum_pk_candidates() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_enum_pk_candidates(d, a)
    Condition
      Error in `dm_enum_pk_candidates()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_enum_fk_candidates() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_enum_fk_candidates(d, a, b)
    Condition
      Error in `dm_enum_fk_candidates()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_rename() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_rename(d, a, y = x)
    Condition
      Error in `dm_rename()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_select() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_select(d, a, x)
    Condition
      Error in `dm_select()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_set_table_description() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_set_table_description(d, a = "test")
    Condition
      Error in `dm_set_table_description()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_get_tables() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_get_tables(d)
    Condition
      Error in `dm_get_tables()`:
      ! Not supported on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# check_cardinality_0_n() - abort_not_subset_of

    Code
      check_cardinality_0_n(parent, child, by_position = TRUE)
    Output
      # A tibble: 1 x 1
            x
        <dbl>
      1     3
    Condition
      Error in `check_cardinality_0_n()`:
      ! Column (`x`) of table child contains values (see examples above) that are not present in column (`x`) of table parent.

# check_cardinality_1_n() - abort_not_unique_key and not_subset_of

    Code
      check_cardinality_1_n(parent, child, by_position = TRUE)
    Condition
      Error in `check_cardinality_1_n()`:
      ! (`x`) not a unique key of `parent`.

# check_subset() - abort_not_subset_of

    Code
      check_subset(child, parent, by_position = TRUE)
    Output
      # A tibble: 1 x 1
            x
        <dbl>
      1     3
    Condition
      Error in `check_subset()`:
      ! Column (`x`) of table child contains values (see examples above) that are not present in column (`x`) of table parent.

