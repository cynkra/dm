test_that("validator is silent", {
  expect_identical(
    expect_silent(validate_dm(new_dm())),
    empty_dm()
  )

  expect_identical(
    expect_silent(validate_dm(dm_for_filter_w_cycle())),
    dm_for_filter_w_cycle()
  )
})

test_that("validator speaks up when something's wrong", {
  # col tracker of non-zoomed dm contains entries
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(col_tracker_zoom = list(1)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of `zoomed_dm` is empty
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = list(NULL)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # col tracker of zoomed dm is empty
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(col_tracker_zoom = list(NULL)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # table name is missing
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(table = "") %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of un-zoomed dm contains a (nonsensical) entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(zoom = list(1)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains a nonsensical entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = if_else(table == "tf_1", list(1), NULL)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains more than one entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = list(tf_1)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # data column of un-zoomed dm contains non-tibble entries
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(data = list(1, 2, 3, 4, 5, 6)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # PK metadata wrong (colname doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(pks = if_else(table == "tf_1", vctrs::list_of(new_pk(list("z"))), pks)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # FK metadata wrong (table doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(fks = if_else(table == "tf_3", vctrs::list_of(new_fk(table = "tf_8", list("z"))), fks)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("validator speaks up (sqlite())", {
  skip_if_not_installed("dbplyr")

  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(data = if_else(table == "tf_1", list(dm_for_filter_sqlite()$tf_1), data)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )
})
