test_that("dm_rename() works for replacing pk", {
  expect_identical(
    dm_rename(dm_for_filter, t3, new_f = f) %>%
      dm_get_all_pks_impl(),
    tribble(
      ~table, ~pk_col,
      "t1",       "a",
      "t2",       "c",
      "t3",   "new_f",
      "t4",       "h",
      "t5",       "k",
      "t6",       "n"
    )
  )
})

test_that("dm_rename() works for replacing fks", {
  expect_identical(
    dm_rename(dm_for_filter, t2, new_d = d, new_e = e) %>%
      dm_get_all_fks_impl(),
    tribble(
      ~child_table, ~child_fk_cols, ~parent_table,
      "t2", "new_d", "t1",
      "t2", "new_e", "t3",
      "t4", "j", "t3",
      "t5", "l", "t4",
      "t5", "m", "t6"
    )
  )
})

test_that("dm_select() works for replacing pk", {
  expect_identical(
    dm_select(dm_for_filter, t3, new_f = f) %>%
      dm_get_all_pks_impl(),
    tribble(
      ~table, ~pk_col,
      "t1",       "a",
      "t2",       "c",
      "t3",   "new_f",
      "t4",       "h",
      "t5",       "k",
      "t6",       "n"
    )
  )
})

test_that("dm_select() keeps pks up to date", {
  expect_identical(
    dm_select(dm_for_filter, t3, new_f = f) %>%
      dm_get_all_pks_impl(),
    dm_get_all_pks_impl(dm_for_filter) %>%
      mutate(pk_col = if_else(table == "t3", "new_f", pk_col))
  )
})

test_that("dm_select() works for replacing fks, and removes missing ones", {
  expect_identical(
    dm_select(dm_for_filter, t2, new_d = d) %>%
      dm_get_all_fks_impl(),
    tribble(
      ~child_table, ~child_fk_cols, ~parent_table,
      "t2", "new_d", "t1",
      "t4", "j", "t3",
      "t5", "l", "t4",
      "t5", "m", "t6"
    )
  )
})

test_that("dm_select() removes fks if not in selection", {
  expect_equivalent(
    dm_select(dm_for_filter, t2, c, e) %>%
      dm_get_all_fks_impl(),
    dm_get_all_fks_impl(dm_for_filter) %>%
      filter(!child_fk_cols == "d")
  )
})
