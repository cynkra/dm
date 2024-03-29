test_that("validator is silent", {
  expect_identical(
    expect_silent(dm_validate(new_dm())),
    empty_dm()
  )

  expect_identical(
    expect_silent(dm_validate(dm_for_filter_w_cycle())),
    dm_for_filter_w_cycle()
  )

  # Corner case
  expect_silent(
    dm(a = tibble(x = 1)) %>%
      dm_add_pk(a, x) %>%
      dm_validate()
  )
})

test_that("validator speaks up when something's wrong", {
  # col tracker of non-zoomed dm contains entries
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(col_tracker_zoom = list(1)) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  # zoom column of `dm_zoomed` is empty
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = list(NULL)) %>%
      dm_from_def(zoomed = TRUE) %>%
      dm_validate(),
    "dm_invalid"
  )

  # col tracker of zoomed dm is empty
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(col_tracker_zoom = list(NULL)) %>%
      dm_from_def(zoomed = TRUE) %>%
      dm_validate(),
    "dm_invalid"
  )

  # table name is missing
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(table = "") %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  # zoom column of un-zoomed dm contains a (nonsensical) entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(zoom = list(1)) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains a nonsensical entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = if_else(table == "tf_1", list(1), list(NULL))) %>%
      dm_from_def(zoomed = TRUE) %>%
      dm_validate(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains more than one entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = list(tf_1)) %>%
      dm_from_def(zoomed = TRUE) %>%
      dm_validate(),
    "dm_invalid"
  )

  # data column of un-zoomed dm contains non-tibble entries
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(data = list(1, 2, 3, 4, 5, 6)) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  # PK metadata wrong (colname doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(pks = if_else(table == "tf_1", list_of(new_pk(list("z"))), pks)) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  # FK metadata wrong (table doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(fks = if_else(
        table == "tf_3",
        list_of(new_fk(ref_column = list("y"), table = "tf_8", column = list("z"), on_delete = "no_action")),
        fks
      )) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  # FK metadata wrong (`column` doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(fks = if_else(table == "tf_1", list_of(new_fk(list("a"), "tf_2", list("z"), "no_action")), fks)) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  # FK metadata wrong (`ref_column` doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(fks = if_else(table == "tf_1", list_of(new_fk(list("z"), "tf_2", list("d"), "no_action")), fks)) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(fks = vctrs::as_list_of(map2(fks, table, ~ if (.y == "tf_2") {
        NULL
      } else {
        .x
      }))) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(pks = vctrs::as_list_of(map2(pks, table, ~ if (.y == "tf_2") {
        NULL
      } else {
        .x
      }))) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )

  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(filters = vctrs::as_list_of(map2(filters, table, ~ if (.y == "tf_2") {
        NULL
      } else {
        .x
      }))) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )
})

test_that("validator speaks up (sqlite())", {
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)) %>%
      dm_from_def() %>%
      dm_validate(),
    "dm_invalid"
  )
})

test_that("validator accepts tbl_sql which is not tbl_dbi (from copy_inline())", {
  skip_if_src("df")

  con <- my_test_con()
  test_table <- dbplyr::copy_inline(con, tibble(a = 1:3))
  # as of dbplyr v2.2.1, `copy_inline()` creates an object that's `tbl_sql`, but not `tbl_dbi`
  testthat::expect_false(inherits(test_table, "tbl_dbi"))
  expect_silent(dm_validate(dm(test_table)))
})
