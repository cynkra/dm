test_that("dm_rename() works for replacing pk", {
  expect_snapshot({
    dm_for_filter() %>%
      dm_rename(tf_3, new_f = f) %>%
      dm_get_all_pks_impl()
  })
})

test_that("dm_rename() works for replacing fks", {
  expect_snapshot({
    dm_for_filter() %>%
      dm_rename(tf_2, new_d = d, new_e = e) %>%
      dm_get_all_fks_impl()
  })
})

test_that("dm_select() works for replacing pk", {
  expect_snapshot({
    dm_for_filter() %>%
      dm_select(tf_3, new_f = f) %>%
      dm_get_all_pks_impl()
  })
})

test_that("dm_select() keeps pks up to date", {
  expect_identical(
    dm_for_filter() %>%
      dm_select(tf_3, f) %>%
      dm_get_all_pks_impl(),
    dm_for_filter() %>%
      dm_get_all_pks_impl() %>%
      filter(table != "tf_3")
  )

  expect_identical(
    dm_for_filter() %>%
      dm_select(tf_3, new_f = f, f1) %>%
      dm_get_all_pks_impl(),
    dm_for_filter() %>%
      dm_get_all_pks_impl() %>%
      # https://github.com/r-lib/vctrs/issues/1371
      mutate(pk_col = new_keys(if_else(table == "tf_3", list(c("new_f", "f1")), unclass(pk_col))))
  )
})

test_that("dm_select() works for replacing fks, and removes missing ones", {
  expect_snapshot({
    dm_for_filter() %>%
      dm_select(tf_2, new_d = d) %>%
      dm_get_all_fks_impl()
  })
})

test_that("dm_select() removes fks if not in selection", {
  expect_equal(
    dm_for_filter() %>%
      dm_select(tf_2, c, e, e1) %>%
      dm_get_all_fks_impl(),
    dm_for_filter() %>%
      dm_get_all_fks_impl() %>%
      filter(child_table != "tf_2" | parent_table != "tf_1")
  )

  expect_equal(
    dm_for_filter() %>%
      dm_select(tf_2, c, e, ex = e1) %>%
      dm_get_all_fks_impl(),
    dm_for_filter() %>%
      dm_get_all_fks_impl() %>%
      filter(child_table != "tf_2" | parent_table != "tf_1") %>%
      mutate(child_fk_cols = new_keys(map(child_fk_cols, ~ gsub("e1", "ex", .x))))
  )

  expect_equal(
    dm_for_filter() %>%
      dm_select(tf_2, c, e) %>%
      dm_get_all_fks_impl(),
    dm_for_filter() %>%
      dm_get_all_fks_impl() %>%
      filter(child_table != "tf_2")
  )
})


# tests for compound keys -------------------------------------------------

test_that("output for compound keys", {
  expect_snapshot({
    dm_select(dm_for_flatten(), fact, dim_1_key_1, dim_1_key_2) %>% dm_paste(options = c("select", "keys"))
    dm_select(dm_for_flatten(), dim_1, dim_1_pk_1, dim_1_pk_2) %>% dm_paste(options = c("select", "keys"))
    dm_select(dm_for_flatten(), fact, -dim_1_key_1) %>% dm_paste(options = c("select", "keys"))
    dm_select(dm_for_flatten(), dim_1, -dim_1_pk_1) %>% dm_paste(options = c("select", "keys"))
  })
})
