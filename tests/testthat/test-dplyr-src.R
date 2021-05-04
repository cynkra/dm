test_that("can access tables", {
  local_options(lifecycle_verbosity = "quiet")

  skip_if_not_installed("nycflights13")

  expect_identical(tbl(dm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_dm_error(
    tbl_impl(dm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("'copy_to.dm()' works", {
  local_options(lifecycle_verbosity = "quiet")

  expect_dm_error(
    copy_to(dm_for_filter(), letters[1:5], name = "letters"),
    "only_data_frames_supported"
  )

  expect_dm_error(
    copy_to(dm_for_filter(), list(mtcars, iris)),
    "only_data_frames_supported"
  )

  expect_dm_error(
    copy_to(dm_for_filter(), mtcars, overwrite = TRUE),
    "no_overwrite"
  )

  skip_if_src_not("df", "mssql")

  # `tibble()` call necessary, #322
  car_table <- test_src_frame(!!!mtcars)

  expect_equivalent_dm(
    suppress_mssql_message(copy_to(dm_for_filter(), mtcars, "car_table")),
    dm_add_tbl(dm_for_filter(), car_table)
  )

  # FIXME: Why do we do name repair in copy_to()?
  expect_equivalent_dm(
    suppress_mssql_message(expect_name_repair_message(
      copy_to(dm_for_filter(), mtcars, "")
    )),
    dm_add_tbl(dm_for_filter(), ...7 = car_table)
  )
})

test_that("'copy_to.dm()' works (2)", {
  local_options(lifecycle_verbosity = "quiet")

  expect_dm_error(
    copy_to(dm(), mtcars, c("car_table", "another_table")),
    "one_name_for_copy_to"
  )

  # rename old and new tables if `repair = unique`
  expect_name_repair_message(
    expect_equivalent_dm(
      copy_to(dm(mtcars), mtcars),
      dm(mtcars...1 = mtcars, mtcars...2 = tibble(mtcars))
    )
  )

  expect_equivalent_dm(
    expect_silent(
      copy_to(dm(mtcars), mtcars, quiet = TRUE)
    ),
    dm(mtcars...1 = mtcars, mtcars...2 = tibble(mtcars))
  )

  # throw error if duplicate table names and `repair = check_unique`
  expect_dm_error(
    dm(mtcars) %>% copy_to(mtcars, repair = "check_unique"),
    "need_unique_names"
  )

  skip_if_not_installed("dbplyr")

  # copying `tibble` from chosen src to sqlite() `dm`
  expect_equivalent_dm(
    copy_to(dm_for_filter_sqlite(), data_card_1(), "test_table"),
    dm_add_tbl(dm_for_filter_sqlite(), test_table = data_card_1_sqlite())
  )

  # copying sqlite() `tibble` to `dm` on src of choice
  expect_equivalent_dm(
    suppress_mssql_message(copy_to(dm_for_filter(), data_card_1_sqlite(), "test_table_1")),
    dm_add_tbl(dm_for_filter(), test_table_1 = data_card_1())
  )
})
