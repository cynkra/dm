test_that("cdm_rename() works for replacing pk", {
  expect_identical(
    cdm_rename(dm_for_filter, t3, new_f = f) %>%
      cdm_get_all_pks(),
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

test_that("cdm_rename() works for replacing fks", {
  expect_identical(
    cdm_rename(dm_for_filter, t2, new_d = d, new_e = e) %>%
      dm_get_all_fks(),
    tribble(
      ~child_table, ~child_fk_col, ~parent_table,
      "t2",               "new_d",          "t1",
      "t2",               "new_e",          "t3",
      "t4",                   "j",          "t3",
      "t5",                   "l",          "t4",
      "t5",                   "m",          "t6"
    )
  )
})

test_that("cdm_select() works for replacing pk", {
  expect_identical(
    cdm_select(dm_for_filter, t3, new_f = f) %>%
      cdm_get_all_pks(),
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

test_that("cdm_select() keeps pks up to date", {
  expect_identical(
    cdm_select(dm_for_filter, t3, new_f = f) %>%
      cdm_get_all_pks(),
    cdm_get_all_pks(dm_for_filter) %>%
      mutate(pk_col = if_else(table == "t3", "new_f", pk_col))
  )
})

test_that("cdm_select() works for replacing fks, and removes missing ones", {
  expect_identical(
    cdm_select(dm_for_filter, t2, new_d = d) %>%
      dm_get_all_fks(),
    tribble(
      ~child_table, ~child_fk_col, ~parent_table,
      "t2",               "new_d",          "t1",
      "t4",                   "j",          "t3",
      "t5",                   "l",          "t4",
      "t5",                   "m",          "t6"
    )
  )
})

test_that("cdm_select() removes fks if not in selection", {
  expect_equivalent(
    cdm_select(dm_for_filter, t2, c, e) %>%
      dm_get_all_fks(),
    dm_get_all_fks(dm_for_filter) %>%
      filter(!child_fk_col == "d")
  )
})
