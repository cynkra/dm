test_that("data source found", {
  expect_false(is_null(my_test_src_fun()))
  expect_silent(my_test_src_fun()())
})

test_that("copy_dm_to() copies data frames to databases", {
  expect_equivalent_dm(
    copy_dm_to(sqlite(), dm_for_filter()),
    dm_for_filter()
  )
})

test_that("copy_dm_to() copies data frames from databases", {
  expect_equivalent_dm(
    copy_dm_to(my_test_src(), dm_for_filter_sqlite()),
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

# set up for test: in order for the unique table names to return the same result each time, we need to trick the function
test_repair_table_names_for_db <- function(table_names, schema, temporary) {
  testthat::with_mock(
    unique_db_table_name = function(table_name) glue::glue("{table_name}_2020_05_15_10_45_29_0"),
    repair_table_names_for_db(table_names, schema, temporary)
  )
}
orig_table_names <- c("t1", "t2", "t3")

test_that("repair_table_names_for_db() works properly", {
  verify_output("out/repair_table_names_for_db.txt", {
    test_repair_table_names_for_db(table_names = orig_table_names, schema = NULL, temporary = TRUE)
    test_repair_table_names_for_db(table_names = orig_table_names, schema = NULL, temporary = FALSE)
    test_repair_table_names_for_db(table_names = orig_table_names, schema = "test", temporary = TRUE)
    test_repair_table_names_for_db(table_names = orig_table_names, schema = "test", temporary = FALSE)
  })
})
