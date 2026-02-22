# dm_add_pk() - abort_key_set_force_false

    Code
      dm_add_pk(d, a, x)
    Condition
      Error in `abort_key_set_force_false()`:
      ! Table a already has a primary key. Use `force = TRUE` to change the existing primary key.

# dm_add_pk() - abort_not_unique_key (via check)

    Code
      dm_add_pk(d, a, x, check = TRUE)
    Condition
      Error in `abort_not_unique_key()`:
      ! (`x`) not a unique key of `a`.

# dm_rm_pk() - abort_pk_not_defined

    Code
      dm_rm_pk(d, a)
    Condition
      Error in `abort_pk_not_defined()`:
      ! No primary keys to remove.

# dm_add_fk() - abort_ref_tbl_has_no_pk

    Code
      dm_add_fk(d, a, x, ref_table = b)
    Condition
      Error in `abort_ref_tbl_has_no_pk()`:
      ! ref_table b needs a primary key first. Use `dm_enum_pk_candidates()` to find appropriate columns and `dm_add_pk()` to define a primary key.

# dm_add_fk() - abort_fk_exists

    Code
      dm_add_fk(d, a, x, ref_table = b)
    Condition
      Error in `abort_fk_exists()`:
      ! (`x`) is already a foreign key of table a into table b.

# dm_add_fk() - abort_not_subset_of (via check)

    Code
      dm_add_fk(d, a, x, ref_table = b, check = TRUE)
    Condition
      Error in `abort_not_subset_of()`:
      ! Column (`x`) of table a contains values (see examples above) that are not present in column (`x`) of table b.

# dm_rm_fk() - abort_is_not_fkc

    Code
      dm_rm_fk(d, a, x, ref_table = b)
    Condition
      Error in `abort_is_not_fkc()`:
      ! No foreign keys to remove.

# dm_add_uk() - abort_no_uk_if_pk (PK exists)

    Code
      dm_add_uk(d, a, x)
    Condition
      Error in `abort_no_uk_if_pk()`:
      ! A PK (`x`) for table a already exists, not adding UK.

# dm_add_uk() - abort_no_uk_if_pk (UK exists)

    Code
      dm_add_uk(d, a, x)
    Condition
      Error in `abort_no_uk_if_pk()`:
      ! A UK (`x`) for table a already exists, not adding UK.

# dm_rm_uk() - abort_uk_not_defined

    Code
      dm_rm_uk(d, a)
    Condition
      Error in `abort_uk_not_defined()`:
      ! No unique keys to remove.

# check_key() - abort_not_unique_key

    Code
      check_key(t, x)
    Condition
      Error in `abort_not_unique_key()`:
      ! (`x`) not a unique key of `t`.

# check_cardinality_1_1() - abort_not_bijective

    Code
      check_cardinality_1_1(parent, child, by_position = TRUE)
    Condition
      Error in `abort_not_bijective()`:
      ! 1..1 cardinality (bijectivity) is not given: Column (`x`) in table child contains duplicate values.

# check_cardinality_0_1() - abort_not_injective

    Code
      check_cardinality_0_1(parent, child, by_position = TRUE)
    Condition
      Error in `abort_not_injective()`:
      ! 0..1 cardinality (injectivity from child table to parent table) is not given: Column (`x`) in table child contains duplicate values.

# dm_set_colors() - abort_only_named_args

    Code
      dm_set_colors(d, a)
    Condition
      Error in `abort_only_named_args()`:
      ! All `...` arguments to function `dm_set_colors()` must be named. The names represent the colors.

# dm_set_colors() - abort_wrong_syntax_set_cols

    Code
      dm_set_colors(d, a = "blue")
    Condition
      Error in `abort_wrong_syntax_set_cols()`:
      ! You seem to be using outdated syntax for `dm_set_colors()`, type `?dm_set_colors()` for examples.

# dm_set_colors() - abort_cols_not_avail

    Code
      dm_set_colors(d, nonexistent_color_xyz = a)
    Condition
      Error in `abort_cols_not_avail()`:
      ! The color "nonexistent_color_xyz" is not available. Call `dm_get_available_colors()` for possible color names or use hex color codes.

# dm_get_con() - abort_con_only_for_dbi

    Code
      dm_get_con(d)
    Condition
      Error in `abort_con_only_for_dbi()`:
      ! A local <dm> doesn't have a DB connection.

# $<-.dm - abort_update_not_supported

    Code
      d$a <- tibble(x = 2)
    Condition
      Error in `abort_update_not_supported()`:
      ! Updating <dm> objects not supported.

# [<-.dm - abort_update_not_supported

    Code
      d[["a"]] <- tibble(x = 2)
    Condition
      Error in `abort_update_not_supported()`:
      ! Updating <dm> objects not supported.

# dm_validate() - abort_is_not_dm

    Code
      dm_validate("not_a_dm")
    Condition
      Error in `abort_is_not_dm()`:
      ! Required class <dm> but instead is <character>.

# dm_validate() - abort_dm_invalid

    Code
      dm_validate(bad)
    Condition
      Error in `abort_dm_invalid()`:
      ! This <dm> is invalid, reason: A `dm` needs to be a list of one item named `def`.

# dm_zoom_to() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_zoom_to(d, b)
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_zoom_to()` on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_update_zoomed() on unzoomed dm - abort_only_possible_w_zoom

    Code
      dm_update_zoomed(d)
    Condition
      Error in `abort_only_possible_w_zoom()`:
      ! You can't call `dm_update_zoomed()` on an unzoomed <dm>. Consider using `dm_zoom_to()` first.

# dm_flatten_to_tbl() with recursive and unsupported join - abort_squash_limited

    Code
      dm_flatten_to_tbl(d, a, .recursive = TRUE, .join = right_join)
    Condition
      Error in `abort_squash_limited()`:
      ! `dm_flatten_to_tbl(.recursive = TRUE)` only supports joins using `left_join()`, `inner_join()`, or `full_join()`.

# dm_flatten_to_tbl() with nest_join - abort_no_flatten_with_nest_join

    Code
      dm_flatten_to_tbl(d, a, .join = nest_join)
    Condition
      Error in `abort_no_flatten_with_nest_join()`:
      ! `dm_..._to_tbl()` can't be called with `join = nest_join`, see the help pages for these functions. Consider `join = left_join`.

# dm_rename_tbl() - abort_need_unique_names

    Code
      dm_rename_tbl(d, a = b)
    Condition
      Error in `abort_need_unique_names()`:
      ! Each new table needs to have a unique name. Duplicate new name: a.

# decompose_table() - abort_dupl_new_id_col_name

    Code
      decompose_table(t, x, y)
    Condition
      Error in `abort_dupl_new_id_col_name()`:
      ! `new_id_column` can't have an identical name as one of the columns of t.

# dm_paste() - abort_unknown_option

    Code
      dm_paste(d, options = "nonexistent_option")
    Condition
      Error in `abort_unknown_option()`:
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
      Error in `abort_sets_not_equal()`:
      ! Column (`x`) of table parent contains values (see examples above) that are not present in column (`x`) of table child.

# dm_draw() - unsupported backend_opts

    Code
      dm_draw(d, backend_opts = list(unsupported_option = TRUE))
    Condition
      Error in `dm_draw()`:
      ! Unsupported `backend_opts` for backend "DiagrammeR": `unsupported_option`.
      i Supported options are: `graph_attrs`, `node_attrs`, `edge_attrs`, `focus`, `graph_name`, `column_arrow`, and `font_size`.

# copy_to.dm() - abort_only_data_frames_supported

    Code
      copy_to(d, 42, name = "b")
    Condition
      Error in `abort_only_data_frames_supported()`:
      ! `copy_to.dm()` only supports class <data.frame> for argument `df`

# copy_to.dm() - abort_no_overwrite

    Code
      copy_to(d, tibble(y = 1), name = "b", overwrite = TRUE)
    Condition
      Error in `abort_no_overwrite()`:
      ! `copy_to.dm()` does not support the `overwrite` argument.

# copy_to.dm() - abort_one_name_for_copy_to

    Code
      copy_to(d, tibble(y = 1), name = c("b", "c"))
    Condition
      Error in `abort_one_name_for_copy_to()`:
      ! Argument `name` in `copy_to.dm()` needs to have length 1, but has length 2 (`b` and `c`)

# pull_tbl() on dm with table not in dm - abort_table_not_in_dm

    Code
      pull_tbl(d, nonexistent)
    Condition
      Error in `abort_table_not_in_dm()`:
      ! Table nonexistent not in <dm> object. Available table names: a.

# pull_tbl() on zoomed dm with wrong table - abort_table_not_zoomed

    Code
      pull_tbl(d, b)
    Condition
      Error in `abort_table_not_zoomed()`:
      ! In `pull_tbl.dm_zoomed()`: Table `b` not zoomed, zoomed tables: `a`.

# dm_flatten_to_tbl() with unrelated tables - abort_tables_not_reachable_from_start

    Code
      dm_flatten_to_tbl(d, a, c)
    Condition
      Error in `abort_tables_not_reachable_from_start()`:
      ! All selected tables must be reachable from `.start`.

# dm_flatten_to_tbl() with grandparent - abort_only_parents

    Code
      dm_flatten_to_tbl(d, a, b, c)
    Condition
      Error in `abort_only_parents()`:
      ! When using `dm_join_to_tbl()`, all join partners of table `.start` must be its direct neighbors. Use `.recursive = TRUE` for recursive flattening.

# dm_flatten_to_tbl() with cycle - abort_no_cycles

    Code
      dm_flatten_to_tbl(dm_for_filter_w_cycle(), tf_5, .recursive = TRUE)
    Condition
      Error in `abort_no_cycles()`:
      ! Cycles in the relationship graph not yet supported.
      i Shortest cycle: tf_5 -> tf_6 -> tf_7 -> tf_2 -> tf_3 -> tf_4 -> tf_5

# dm_select_tbl() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_select_tbl(d, a)
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_select_tbl()` on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_add_pk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_add_pk(d, b, x)
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_add_pk()` on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_add_fk() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_add_fk(d, a, x, ref_table = b)
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_add_fk()` on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_get_con() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_get_con(d)
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_get_con()` on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_insert_zoomed() on unzoomed dm - abort_only_possible_w_zoom

    Code
      dm_insert_zoomed(d)
    Condition
      Error in `abort_only_possible_w_zoom()`:
      ! You can't call `dm_insert_zoomed()` on an unzoomed <dm>. Consider using `dm_zoom_to()` first.

# dm_draw() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_draw(d)
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_draw()` on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

# dm_paste() on zoomed dm - abort_only_possible_wo_zoom

    Code
      dm_paste(d)
    Condition
      Error in `abort_only_possible_wo_zoom()`:
      ! You can't call `dm_paste_impl()` on a <dm_zoomed>. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

