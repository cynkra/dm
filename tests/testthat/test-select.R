test_that("dm_rename() works for replacing pk", {
  expect_identical(
    dm_rename(dm_for_filter(), tf_3, new_f = f) %>%
      dm_get_all_pks2_impl(),
    tribble(
      ~table, ~pk_col,
      "tf_1",     "a",
      "tf_2",     "c",
      "tf_3", "new_f",
      "tf_4",     "h",
      "tf_5",     "k",
      "tf_6",     "n"
    ) %>%
      mutate(pk_col = new_keys(pk_col))
  )
})

test_that("dm_rename() works for replacing fks", {
  expect_identical(
    dm_rename(dm_for_filter(), tf_2, new_d = d, new_e = e) %>%
      dm_get_all_fks2_impl(),
    tribble(
      ~child_table, ~child_fk_cols, ~parent_table, ~parent_pk_cols,
      "tf_2",       "new_d",        "tf_1",        "a",
      "tf_2",       "new_e",        "tf_3",        "f",
      "tf_4",       "j",            "tf_3",        "f",
      "tf_5",       "l",            "tf_4",        "h",
      "tf_5",       "m",            "tf_6",        "n",
    ) %>%
      mutate(child_fk_cols = new_keys(child_fk_cols), parent_pk_cols = new_keys(parent_pk_cols))
  )
})

test_that("dm_select() works for replacing pk", {
  expect_identical(
    dm_select(dm_for_filter(), tf_3, new_f = f) %>%
      dm_get_all_pks2_impl(),
    tribble(
      ~table, ~pk_col,
      "tf_1",     "a",
      "tf_2",     "c",
      "tf_3", "new_f",
      "tf_4",     "h",
      "tf_5",     "k",
      "tf_6",     "n"
    ) %>%
      mutate(pk_col = new_keys(pk_col))
  )
})

test_that("dm_select() keeps pks up to date", {
  expect_identical(
    dm_select(dm_for_filter(), tf_3, new_f = f) %>%
      dm_get_all_pks2_impl(),
    dm_for_filter() %>%
      dm_get_all_pks2_impl() %>%
      # https://github.com/r-lib/vctrs/issues/1371
      mutate(pk_col = new_keys(if_else(table == "tf_3", list("new_f"), unclass(pk_col))))
  )
})

test_that("dm_select() works for replacing fks, and removes missing ones", {
  expect_identical(
    dm_select(dm_for_filter(), tf_2, new_d = d) %>%
      dm_get_all_fks2_impl(),
    tribble(
      ~child_table, ~child_fk_cols, ~parent_table, ~parent_pk_cols,
      "tf_2",       "new_d",        "tf_1",        "a",
      "tf_4",       "j",            "tf_3",        "f",
      "tf_5",       "l",            "tf_4",        "h",
      "tf_5",       "m",            "tf_6",        "n",
    ) %>%
      mutate(child_fk_cols = new_keys(child_fk_cols), parent_pk_cols = new_keys(parent_pk_cols))
  )
})

test_that("dm_select() removes fks if not in selection", {
  expect_equal(
    dm_for_filter() %>%
      dm_select(tf_2, c, e) %>%
      dm_get_all_fks2_impl(),
    dm_for_filter() %>%
      dm_get_all_fks2_impl() %>%
      filter(child_fk_cols != new_keys("d"))
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
