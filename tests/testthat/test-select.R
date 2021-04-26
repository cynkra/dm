test_that("dm_rename() works for replacing pk", {
  expect_identical(
    dm_rename(dm_for_filter(), tf_3, new_f = f) %>%
      dm_get_all_pks_impl(),
    tribble(
      ~table, ~pk_col,
      "tf_1",     "a",
      "tf_2",     "c",
      "tf_3", "new_f",
      "tf_4",     "h",
      "tf_5",     "k",
      "tf_6",     "n"
    )
  )
})

test_that("dm_rename() works for replacing fks", {
  expect_identical(
    dm_rename(dm_for_filter(), tf_2, new_d = d, new_e = e) %>%
      dm_get_all_fks_impl(),
    tribble(
      ~child_table, ~child_fk_cols, ~parent_table, ~parent_pk_cols,
      "tf_2",       "new_d",        "tf_1",        "a",
      "tf_2",       "new_e",        "tf_3",        "f",
      "tf_4",       "j",            "tf_3",        "f",
      "tf_5",       "l",            "tf_4",        "h",
      "tf_5",       "m",            "tf_6",        "n",
    )
  )
})

test_that("dm_select() works for replacing pk", {
  expect_identical(
    dm_select(dm_for_filter(), tf_3, new_f = f) %>%
      dm_get_all_pks_impl(),
    tribble(
      ~table, ~pk_col,
      "tf_1",     "a",
      "tf_2",     "c",
      "tf_3", "new_f",
      "tf_4",     "h",
      "tf_5",     "k",
      "tf_6",     "n"
    )
  )
})

test_that("dm_select() keeps pks up to date", {
  expect_identical(
    dm_select(dm_for_filter(), tf_3, new_f = f) %>%
      dm_get_all_pks_impl(),
    dm_get_all_pks_impl(dm_for_filter()) %>%
      mutate(pk_col = if_else(table == "tf_3", "new_f", pk_col))
  )
})

test_that("dm_select() works for replacing fks, and removes missing ones", {
  expect_identical(
    dm_select(dm_for_filter(), tf_2, new_d = d) %>%
      dm_get_all_fks_impl(),
    tribble(
      ~child_table, ~child_fk_cols, ~parent_table, ~parent_pk_cols,
      "tf_2",       "new_d",        "tf_1",        "a",
      "tf_4",       "j",            "tf_3",        "f",
      "tf_5",       "l",            "tf_4",        "h",
      "tf_5",       "m",            "tf_6",        "n",
    )
  )
})

test_that("dm_select() removes fks if not in selection", {
  expect_equal(
    dm_select(dm_for_filter(), tf_2, c, e) %>%
      dm_get_all_fks_impl(),
    dm_get_all_fks_impl(dm_for_filter()) %>%
      filter(!child_fk_cols == "d")
  )
})


# tests for compound keys -------------------------------------------------

verify_output(
  "out/compound-select.txt", {
    dm_select(nyc_comp(), weather, -origin)
    dm_select(nyc_comp(), weather, origin, time_hour)
    dm_select(nyc_comp(), flights, -time_hour)
    dm_select(nyc_comp(), flights, -origin)
  }
)
