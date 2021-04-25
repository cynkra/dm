test_that("dm_select_tbl() selects a part of a larger `dm` as a reduced `dm`?", {
  def <-
    dm_for_filter() %>%
    dm_rm_fk(tf_5, m, tf_6) %>%
    dm_rm_fk(tf_2, d, tf_1) %>%
    dm_get_def()

  dm_for_filter_smaller <- new_dm3(def[def$table %in% c("tf_1", "tf_6"), ])

  expect_equivalent_dm(
    dm_select_tbl(dm_for_filter(), -tf_2, -tf_3, -tf_4, -tf_5),
    dm_for_filter_smaller
  )
})

test_that("dm_select_tbl() can reorder the tables in a `dm`", {
  reordered_dm_for_filter <-
    dm_for_filter() %>%
    dm_get_def() %>%
    arrange(c(3:1, 6:4)) %>%
    new_dm3()

  expect_equivalent_dm(
    dm_select_tbl(dm_for_filter(), tf_3:tf_1, tf_6:tf_4),
    reordered_dm_for_filter
  )
})

test_that("dm_select_tbl() remembers all FKs", {
  skip_if_not_installed("nycflights13")

  reordered_dm_nycflights_small_cycle <-
    dm_nycflights_small() %>%
    dm_add_fk(flights, origin, airports) %>%
    dm_get_def() %>%
    filter(!(table %in% c("airlines", "planes"))) %>%
    slice(2:1) %>%
    new_dm3()

  expect_equivalent_dm(
    dm_add_fk(dm_nycflights_small(), flights, origin, airports) %>%
      dm_select_tbl(airports, flights),
    reordered_dm_nycflights_small_cycle
  )
})


test_that("dm_rename_tbl() renames a `dm`", {
  # FIXME: PR #313: do these test-tibbles here also need to be copied to `my_test_src()`?
  dm_rename <-
    as_dm(list(a = tibble(x = 1), b = tibble(y = 1))) %>%
    dm_add_pk(b, y) %>%
    dm_add_fk(a, x, b)

  dm_rename_a <-
    as_dm(list(c = tibble(x = 1), b = tibble(y = 1))) %>%
    dm_add_pk(b, y) %>%
    dm_add_fk(c, x, b)

  dm_rename_b <-
    as_dm(list(a = tibble(x = 1), e = tibble(y = 1))) %>%
    dm_add_pk(e, y) %>%
    dm_add_fk(a, x, e)

  dm_rename_bd <-
    as_dm(list(a = tibble(x = 1), d = tibble(y = 1))) %>%
    dm_add_pk(d, y) %>%
    dm_add_fk(a, x, d)

  expect_equivalent_dm(
    dm_rename_tbl(dm_rename, c = a),
    dm_rename_a
  )

  expect_equivalent_dm(
    dm_rename_tbl(dm_rename, e = b),
    dm_rename_b
  )

  skip("dm argument")
  expect_equivalent_dm(
    dm_rename_tbl(dm_rename, d = b),
    dm_rename_bd
  )
})

test_that("errors for selecting and renaming tables work", {
  expect_error(
    dm_select_tbl(dm_for_filter(), t_new = c(tf_1, tf_2)),
    class = "vctrs_error_names_must_be_unique"
  )

  expect_error(
    dm_rename_tbl(dm_for_filter(), t_new = c(tf_1, tf_2)),
    class = "vctrs_error_names_must_be_unique"
  )
})
