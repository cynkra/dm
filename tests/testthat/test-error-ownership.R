# End-to-end snapshot tests for error ownership
# Each test triggers an error through exported functions to track that the
# error is reported with the correct origin (the exported function name).

test_that("dm_add_pk() - abort_key_set_force_false", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_add_pk(a, x)
  expect_snapshot(error = TRUE, {
    dm_add_pk(d, a, x)
  })
})

test_that("dm_add_pk() - abort_not_unique_key (via check)", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = c(1, 1)))
  expect_snapshot(error = TRUE, {
    dm_add_pk(d, a, x, check = TRUE)
  })
})

test_that("dm_rm_pk() - abort_pk_not_defined", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_rm_pk(d, a)
  })
})

test_that("dm_add_fk() - abort_ref_tbl_has_no_pk", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_add_fk(d, a, x, ref_table = b)
  })
})

test_that("dm_add_fk() - abort_fk_exists", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_fk(a, x, ref_table = b)
  expect_snapshot(error = TRUE, {
    dm_add_fk(d, a, x, ref_table = b)
  })
})

test_that("dm_add_fk() - abort_not_subset_of (via check)", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 2), b = tibble(x = 1)) %>% dm_add_pk(b, x)
  expect_snapshot(error = TRUE, {
    dm_add_fk(d, a, x, ref_table = b, check = TRUE)
  })
})

test_that("dm_rm_fk() - abort_is_not_fkc", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_rm_fk(d, a, x, ref_table = b)
  })
})

test_that("dm_add_uk() - abort_no_uk_if_pk (PK exists)", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_add_pk(a, x)
  expect_snapshot(error = TRUE, {
    dm_add_uk(d, a, x)
  })
})

test_that("dm_add_uk() - abort_no_uk_if_pk (UK exists)", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_add_uk(a, x)
  expect_snapshot(error = TRUE, {
    dm_add_uk(d, a, x)
  })
})

test_that("dm_rm_uk() - abort_uk_not_defined", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_rm_uk(d, a)
  })
})

test_that("check_key() - abort_not_unique_key", {
  local_options(lifecycle_verbosity = "quiet")

  t <- tibble(x = c(1, 1))
  expect_snapshot(error = TRUE, {
    check_key(t, x)
  })
})

test_that("check_cardinality_1_1() - abort_not_bijective", {
  local_options(lifecycle_verbosity = "quiet")

  parent <- tibble(x = 1:3)
  child <- tibble(x = c(1, 1, 2, 3))
  expect_snapshot(error = TRUE, {
    check_cardinality_1_1(parent, child, by_position = TRUE)
  })
})

test_that("check_cardinality_0_1() - abort_not_injective", {
  local_options(lifecycle_verbosity = "quiet")

  parent <- tibble(x = 1:4)
  child <- tibble(x = c(1, 1, 2))
  expect_snapshot(error = TRUE, {
    check_cardinality_0_1(parent, child, by_position = TRUE)
  })
})

test_that("dm_set_colors() - abort_only_named_args", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_set_colors(d, a)
  })
})

test_that("dm_set_colors() - abort_wrong_syntax_set_cols", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_set_colors(d, a = "blue")
  })
})

test_that("dm_set_colors() - abort_cols_not_avail", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_set_colors(d, nonexistent_color_xyz = a)
  })
})

test_that("dm_get_con() - abort_con_only_for_dbi", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_get_con(d)
  })
})

test_that("$<-.dm - abort_update_not_supported", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    d$a <- tibble(x = 2)
  })
})

test_that("[<-.dm - abort_update_not_supported", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    d[["a"]] <- tibble(x = 2)
  })
})

test_that("dm_validate() - abort_is_not_dm", {
  local_options(lifecycle_verbosity = "quiet")

  expect_snapshot(error = TRUE, {
    dm_validate("not_a_dm")
  })
})

test_that("dm_validate() - abort_dm_invalid", {
  local_options(lifecycle_verbosity = "quiet")

  bad <- structure(list(bad = "dm"), class = "dm")
  expect_snapshot(error = TRUE, {
    dm_validate(bad)
  })
})

test_that("dm_zoom_to() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_zoom_to(d, b)
  })
})

test_that("dm_update_zoomed() on unzoomed dm - abort_only_possible_w_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_update_zoomed(d)
  })
})

test_that("dm_flatten_to_tbl() with recursive and unsupported join - abort_squash_limited", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_fk(a, x, ref_table = b)
  expect_snapshot(error = TRUE, {
    dm_flatten_to_tbl(d, a, .recursive = TRUE, .join = right_join)
  })
})

test_that("dm_flatten_to_tbl() with nest_join - abort_no_flatten_with_nest_join", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_fk(a, x, ref_table = b)
  expect_snapshot(error = TRUE, {
    dm_flatten_to_tbl(d, a, .join = nest_join)
  })
})

test_that("dm_rename_tbl() - abort_need_unique_names", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_rename_tbl(d, a = b)
  })
})

test_that("decompose_table() - abort_dupl_new_id_col_name", {
  local_options(lifecycle_verbosity = "quiet")

  t <- tibble(x = 1, y = 2)
  expect_snapshot(error = TRUE, {
    decompose_table(t, x, y)
  })
})

test_that("dm_paste() - abort_unknown_option", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_paste(d, options = "nonexistent_option")
  })
})

test_that("check_set_equality() - abort_sets_not_equal", {
  local_options(lifecycle_verbosity = "quiet")

  parent <- tibble(x = 1:3)
  child <- tibble(x = c(1, 2))
  expect_snapshot(error = TRUE, {
    check_set_equality(parent, child, by_position = TRUE)
  })
})

test_that("dm_draw() - unsupported backend_opts", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_draw(d, backend_opts = list(unsupported_option = TRUE))
  })
})

test_that("copy_to.dm() - abort_only_data_frames_supported", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    copy_to(d, 42, name = "b")
  })
})

test_that("copy_to.dm() - abort_no_overwrite", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    copy_to(d, tibble(y = 1), name = "b", overwrite = TRUE)
  })
})

test_that("copy_to.dm() - abort_one_name_for_copy_to", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    copy_to(d, tibble(y = 1), name = c("b", "c"))
  })
})

test_that("pull_tbl() on dm with table not in dm - abort_table_not_in_dm", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    pull_tbl(d, nonexistent)
  })
})

test_that("pull_tbl() on zoomed dm with wrong table - abort_table_not_zoomed", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    pull_tbl(d, b)
  })
})

test_that("dm_flatten_to_tbl() with unrelated tables - abort_tables_not_reachable_from_start", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1), c = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_fk(a, x, ref_table = b)
  expect_snapshot(error = TRUE, {
    dm_flatten_to_tbl(d, a, c)
  })
})

test_that("dm_flatten_to_tbl() with grandparent - abort_only_parents", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1), c = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_pk(c, x) %>%
    dm_add_fk(a, x, ref_table = b) %>%
    dm_add_fk(b, x, ref_table = c)
  expect_snapshot(error = TRUE, {
    dm_flatten_to_tbl(d, a, b, c)
  })
})

test_that("dm_flatten_to_tbl() with cycle - abort_no_cycles", {
  local_options(lifecycle_verbosity = "quiet")

  expect_snapshot(error = TRUE, {
    dm_flatten_to_tbl(dm_for_filter_w_cycle(), tf_5, .recursive = TRUE)
  })
})

test_that("dm_select_tbl() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_select_tbl(d, a)
  })
})

test_that("dm_add_pk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_add_pk(d, b, x)
  })
})

test_that("dm_add_fk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_add_fk(d, a, x, ref_table = b)
  })
})

test_that("dm_get_con() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_get_con(d)
  })
})

test_that("dm_insert_zoomed() on unzoomed dm - abort_only_possible_w_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    dm_insert_zoomed(d)
  })
})

test_that("dm_draw() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_draw(d)
  })
})

test_that("dm_paste() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_paste(d)
  })
})

# --- Additional error conditions ---

test_that("dm_flatten() - abort_tables_not_neighbors", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1), c = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_fk(a, x, ref_table = b)
  expect_snapshot(error = TRUE, {
    dm_flatten(d, a, parent_tables = c)
  })
})

test_that("pull_tbl() - abort_no_table_provided", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_snapshot(error = TRUE, {
    pull_tbl(d, )
  })
})

test_that("dm_flatten_to_tbl() - abort_no_flatten_with_nest_join (via dm_join_to_tbl)", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_fk(a, x, ref_table = b)
  expect_snapshot(error = TRUE, {
    dm_join_to_tbl(d, a, b, join = nest_join)
  })
})

test_that("dm_examine_constraints() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_examine_constraints(d)
  })
})

test_that("dm_disambiguate_cols() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_disambiguate_cols(d)
  })
})

test_that("dm_rm_pk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>%
    dm_add_pk(a, x) %>%
    dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_rm_pk(d, a)
  })
})

test_that("dm_rm_fk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_add_fk(a, x, ref_table = b) %>%
    dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_rm_fk(d, a, x, ref_table = b)
  })
})

test_that("dm_add_uk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_add_uk(d, a, x)
  })
})

test_that("dm_rm_uk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>%
    dm_add_uk(a, x) %>%
    dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_rm_uk(d, a)
  })
})

test_that("dm_has_pk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_has_pk(d, a)
  })
})

test_that("dm_get_pk() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_get_pk(d, a)
  })
})

test_that("dm_get_all_pks() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_get_all_pks(d)
  })
})

test_that("dm_get_all_fks() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_get_all_fks(d)
  })
})

test_that("dm_get_all_uks() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_get_all_uks(d)
  })
})

test_that("dm_enum_pk_candidates() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_enum_pk_candidates(d, a)
  })
})

test_that("dm_enum_fk_candidates() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
    dm_add_pk(b, x) %>%
    dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_enum_fk_candidates(d, a, b)
  })
})

test_that("dm_rename() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_rename(d, a, y = x)
  })
})

test_that("dm_select() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_select(d, a, x)
  })
})

test_that("dm_discard_zoomed() on unzoomed dm returns silently", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1))
  expect_identical(dm_discard_zoomed(d), d)
})

test_that("dm_set_table_description() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_set_table_description(d, a = "test")
  })
})

test_that("dm_get_tables() on zoomed dm - abort_only_possible_wo_zoom", {
  local_options(lifecycle_verbosity = "quiet")

  d <- dm(a = tibble(x = 1)) %>% dm_zoom_to(a)
  expect_snapshot(error = TRUE, {
    dm_get_tables(d)
  })
})

test_that("check_cardinality_0_n() - abort_not_subset_of", {
  local_options(lifecycle_verbosity = "quiet")

  parent <- tibble(x = 1:2)
  child <- tibble(x = c(1, 3))
  expect_snapshot(error = TRUE, {
    check_cardinality_0_n(parent, child, by_position = TRUE)
  })
})

test_that("check_cardinality_1_n() - abort_not_unique_key and not_subset_of", {
  local_options(lifecycle_verbosity = "quiet")

  parent <- tibble(x = c(1, 1))
  child <- tibble(x = c(1, 2))
  expect_snapshot(error = TRUE, {
    check_cardinality_1_n(parent, child, by_position = TRUE)
  })
})

test_that("check_subset() - abort_not_subset_of", {
  local_options(lifecycle_verbosity = "quiet")

  parent <- tibble(x = 1:2)
  child <- tibble(x = c(1, 3))
  expect_snapshot(error = TRUE, {
    check_subset(child, parent, by_position = TRUE)
  })
})
