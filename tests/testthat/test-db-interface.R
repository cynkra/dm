test_that("data source found", {
  expect_false(is_null(my_test_src_fun()))
  expect_silent(my_test_src_fun()())
})

skip_if_not_installed("dbplyr")

test_that("copy_dm_to() copies data frames to databases", {
  skip_if_local_src()

  expect_equivalent_dm(
    copy_dm_to(my_test_src(), collect(dm_for_filter())),
    dm_for_filter()
  )

  # FIXME: How to test writing permanent tables without and be sure they are removed at the end independent what 'my_test_src()' is?
})

test_that("copy_dm_to() copies data frames from any source", {
  expect_equivalent_dm(
    expect_deprecated(
      copy_dm_to(default_local_src(), dm_for_filter())
    ),
    dm_for_filter()
  )
})

test_that("copy_dm_to() copies to SQLite", {
  skip_if_not_installed("RSQLite")

  expect_equivalent_dm(
    copy_dm_to(test_src_sqlite(), dm_for_filter()),
    dm_for_filter()
  )
})

test_that("copy_dm_to() copies from SQLite", {
  skip_if_local_src()
  skip_if_not_installed("RSQLite")

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

test_that("copy_dm_to() fails with duplicate table names", {
  skip_if_local_src()

  bad_names <- set_names(names(dm_for_filter()))
  bad_names[[2]] <- bad_names[[1]]

  expect_dm_error(
    copy_dm_to(my_test_src(), dm_for_filter(), table_names = bad_names),
    class = "copy_dm_to_table_names_duplicated"
  )
})

test_that("default table repair works", {
  skip_if_local_src()

  con <- con_from_src_or_con(my_test_src())

  table_names <- c("t1", "t2", "t3")

  calls <- 0

  my_unique_db_table_name <- function(table_name) {
    calls <<- calls + 1
    glue::glue("{table_name}_2020_05_15_10_45_29_0")
  }

  mockr::with_mock(
    unique_db_table_name = my_unique_db_table_name,
    {
      repair_table_names_for_db(table_names, temporary = FALSE, con)
      expect_equal(calls, 0)
      repair_table_names_for_db(table_names, temporary = TRUE, con)
      expect_gt(calls, 0)
    },
    .env = asNamespace("dm")
  )
})

test_that("table identifiers are quoted", {
  skip_if_local_src()

  # Implicitly created with copy_dm_to()
  dm <- dm_test_obj()
  remote_names <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  con <- dm_get_con(dm)
  pattern <- unclass(DBI::dbQuoteIdentifier(con, "[a-z0-9_#]+"))
  expect_true(all(grepl(pattern, remote_names)))
})
