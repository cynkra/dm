test_that("can access tables", {
  expect_identical(tbl(cdm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_cdm_error(
    tbl(cdm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("can create dm with as_dm()", {
  test_obj_df <- as_dm(cdm_get_tables(cdm_test_obj))

  walk(
    cdm_test_obj_src, ~ expect_equivalent_dm(as_dm(cdm_get_tables(.)), test_obj_df)
  )
})

test_that("creation of empty `dm` works", {
  expect_true(
    is_empty(dm())
  )

  expect_true(
    is_empty(new_dm())
  )
})

test_that("'copy_to.dm()' works", {
  expect_cdm_error(
    copy_to(dm_for_filter, list(mtcars, iris)),
    "one_name_for_each_table"
  )

  expect_cdm_error(
    copy_to(dm_for_filter, letters[1:5], name = "letters"),
    "only_data_frames_supported"
  )

  expect_equivalent_dm(
    copy_to(dm_for_filter, mtcars, "car_table"),
    cdm_add_tbl(dm_for_filter, car_table = mtcars)
  )

  # copying local `tibble` to postgres `dm`
  skip_if_error(
    expect_equivalent_dm(
      copy_to(dm_for_filter_src$postgres, d1_src$df, "test_table"),
      cdm_add_tbl(dm_for_filter_src$postgres, test_table = d1_src$postgres)
      )
  )

  # copying list of postgres `tibbles` to local `dm`
  skip_if_error(
    expect_equivalent_dm(
      copy_to(dm_for_filter_src$df, list(d1_src$postgres, d2_src$postgres), c("test_table_1", "test_table_2")),
      cdm_add_tbl(dm_for_filter_src$df, test_table_1 = d1_src$df, test_table_2 = d2_src$df)
    )
  )
})
