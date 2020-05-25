test_that("data source found", {
  expect_false(is_null(my_test_src_fun()))
  expect_silent(my_test_src_fun()())
})

test_that("copy_dm_to() copies data frames to databases", {
  expect_equivalent_dm(
    copy_dm_to(sqlite(), dm_for_filter(), unique_table_names = TRUE),
    dm_for_filter()
  )
})

test_that("copy_dm_to() copies data frames from databases", {
  expect_equivalent_dm(
    copy_dm_to(my_test_src(), dm_for_filter_sqlite(), unique_table_names = TRUE),
    dm_for_filter_sqlite()
  )
})

# FIXME: Add test that set_key_constraints = FALSE doesn't set key constraints,
# in combination with dm_learn_from_db

test_that("copy_dm_to() rejects overwrite and types arguments", {
  expect_dm_error(
    copy_dm_to(my_test_src(), dm_for_filter(), overwrite = TRUE),
    class = "no_overwrite"
  )

  expect_dm_error(
    copy_dm_to(my_test_src(), dm_for_filter(), types = character()),
    class = "no_types"
  )
})
