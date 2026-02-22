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
