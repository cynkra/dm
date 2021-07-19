test_that("read and write csv/zip/xlsx works", {
  skip_if_remote_src()

  test_path <- "___test_path"
  test_path_2 <- "___test_path_2"
  test_path_3 <- "___test_path_3"


  withr::defer({
    unlink(test_path, recursive = TRUE)
    unlink(test_path_2, recursive = TRUE)
    unlink(test_path_3, recursive = TRUE)
  })

  # writing into a non-existing directory
  expect_message(
    dm_write_csv(dm_for_filter(), csv_directory = test_path),
    "csv files"
  )

  expect_equivalent_dm(
    dm_for_filter(),
    dm_read_csv(test_path)
  )


  expect_dm_error(
    dm_write_csv(dm_for_filter(), csv_directory = test_path),
    "dir_not_empty"
  )

  # writing into an existing empty directory
  dir.create(test_path_2)

  expect_message(
    dm_write_csv(dm_for_filter(), csv_directory = test_path_2),
    "csv files"
  )

  expect_equivalent_dm(
    dm_for_filter(),
    dm_read_csv(test_path_2)
  )

  # error if special files are missing
  walk(
    file.path(test_path_2, c("___info_file_dm.csv", "___coltypes_file_dm.csv")),
    file.remove
  )

  expect_dm_error(
    dm_read_csv(test_path_2),
    "files_or_sheets_missing"
  )

  expect_message(
    dm_write_zip(dm_for_filter(), zip_file_path = file.path(test_path, "dm.zip")),
    "zip file"
  )

  expect_equivalent_dm(
    dm_for_filter(),
    dm_read_zip(file.path(test_path, "dm.zip"))
  )


  expect_message(
    dm_write_xlsx(dm_for_filter(), xlsx_file_path = file.path(test_path, "dm.xlsx")),
    "xlsx file"
  )

  expect_equivalent_dm(
    dm_for_filter(),
    dm_read_xlsx(file.path(test_path, "dm.xlsx"))
  )

  expect_dm_error(
    dm_write_zip(dm_for_filter(), zip_file_path = file.path(test_path, "dm.zip")),
    "file_exists"
  )

  expect_dm_error(
    dm_write_xlsx(dm_for_filter(), xlsx_file_path = file.path(test_path, "dm.xlsx")),
    "file_exists"
  )

  expect_message(
    expect_message(
      dm_write_zip(
        dm_for_filter(),
        zip_file_path = file.path(test_path, "dm.zip"),
        overwrite = TRUE),
      "Overwriting file"),
    "zip file"
  )

  expect_equivalent_dm(
    dm_for_filter(),
    dm_read_zip(file.path(test_path, "dm.zip"))
  )

  expect_message(
    expect_message(
      dm_write_xlsx(
        dm_for_filter(),
        xlsx_file_path = file.path(test_path, "dm.xlsx"),
        overwrite = TRUE),
      "Overwriting file"),
    "xlsx file"
  )

  expect_equivalent_dm(
    dm_for_filter(),
    dm_read_xlsx(file.path(test_path, "dm.xlsx"))
  )

  # check for simple errors
  expect_dm_error(
    dm_write_zip(
      1,
      zip_file_path = file.path(test_path, "dm.zip"),
      overwrite = TRUE),
    "parameter_not_correct_class"
  )

  expect_dm_error(
    dm_write_zip(
      dm_for_filter() %>% dm_zoom_to(tf_1),
      zip_file_path = file.path(test_path, "dm.zip"),
      overwrite = TRUE),
    "only_possible_wo_zoom"
  )

  expect_dm_error(
    dm_write_zip(
      dm_for_filter() %>% dm_filter(tf_1, a == 1),
      zip_file_path = file.path(test_path, "dm.zip"),
      overwrite = TRUE),
    "only_possible_wo_filters"
  )

  # - case of no keys
  # - case of date or time columns
  no_key_date_time_bool_dm <- dm(
    date_tbl = tibble(a = as.Date("2021-03-03")),
    time_tbl = tibble(a = as.POSIXct("2021-03-03 09:16:00", tz = "UTC")),
    bool_tbl = tibble(l = c(TRUE, FALSE, TRUE))
  )

  expect_message(
    expect_message(
      dm_write_csv(no_key_date_time_bool_dm, csv_directory = test_path_3),
      "csv files"
    ),
    "`UTC`"
  )

  expect_equivalent_dm(
    no_key_date_time_bool_dm,
    dm_read_csv(test_path_3)
  )

  expect_message(
    expect_message(
      dm_write_zip(no_key_date_time_bool_dm, zip_file_path = file.path(test_path_3, "dm.zip")),
      "zip file"
    ),
    "`UTC`"
  )

  expect_equivalent_dm(
    no_key_date_time_bool_dm,
    dm_read_zip(file.path(test_path_3, "dm.zip"))
  )

  expect_message(
    expect_message(
      dm_write_xlsx(no_key_date_time_bool_dm, xlsx_file_path = file.path(test_path_3, "dm.xlsx")),
      "xlsx file"
      ),
    "`UTC`"
  )

  expect_equivalent_dm(
    no_key_date_time_bool_dm,
    dm_read_xlsx(file.path(test_path_3, "dm.xlsx"))
  )


  # in case of `empty_dm()`
  expect_dm_error(
    dm_write_zip(empty_dm(), zip_file_path = file.path(test_path_3, "dm.zip"), overwrite = TRUE),
    "empty_dm"
  )

  expect_dm_error(
    dm_write_xlsx(empty_dm(), xlsx_file_path = file.path(test_path_3, "dm.xlsx"), overwrite = TRUE),
    "empty_dm"
  )
})
