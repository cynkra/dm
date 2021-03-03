test_that("read and write csv/zip works", {
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
    expect_identical(
      dm_for_filter(),
      dm_write_csv(dm_for_filter(), csv_directory = test_path) %>% dm_read_csv()
    ),
    "csv-files"
  )

  expect_dm_error(
    dm_write_csv(dm_for_filter(), csv_directory = test_path),
    "dir_not_empty"
  )

  # writing into an existing empty directory
  dir.create(test_path_2)

  expect_message(
    expect_identical(
      dm_for_filter(),
      dm_write_csv(dm_for_filter(), csv_directory = test_path_2) %>% dm_read_csv()
    ),
    "csv-files"
  )

  # error if special files are missing
  walk(
    file.path(test_path_2, c("___info_file_dm.csv", "___coltypes_file_dm.csv")),
    file.remove
  )

  expect_dm_error(
    dm_read_csv(test_path_2),
    "files_missing"
  )

  expect_message(
    expect_identical(
      dm_for_filter(),
      dm_write_zip(dm_for_filter(), zip_file_path = file.path(test_path, "dm.zip")) %>% dm_read_zip()
    ),
    "zip-file"
  )

  expect_dm_error(
    dm_write_zip(dm_for_filter(), zip_file_path = file.path(test_path, "dm.zip")),
    "file_exists"
  )

  expect_message(
    expect_message(
      expect_identical(
        dm_for_filter(),
        dm_write_zip(
          dm_for_filter(),
          zip_file_path = file.path(test_path, "dm.zip"),
          overwrite = TRUE) %>%
          dm_read_zip()
      ),
      "Overwriting file"
    ),
    "zip-file"
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
  no_key_date_time_dm <- dm(
    date_tbl = tibble(a = as.Date("2021-03-03")),
    time_tbl = tibble(a = as.POSIXct("2021-03-03 09:16:00", tz = "UTC"))
  )

  expect_message(
    expect_message(
      expect_identical(
        no_key_date_time_dm,
        dm_write_csv(no_key_date_time_dm, csv_directory = test_path_3) %>% dm_read_csv()
      ),
      "csv-files"
    ),
    "`UTC`"
  )

  expect_message(
    expect_message(
      expect_identical(
        no_key_date_time_dm,
        dm_write_zip(no_key_date_time_dm, zip_file_path = file.path(test_path_3, "dm.zip")) %>% dm_read_zip()
      ),
      "zip-file"
    ),
    "`UTC`"
  )

  # in case of `empty_dm()`
  expect_dm_error(
    dm_write_zip(empty_dm(), zip_file_path = file.path(test_path_3, "dm.zip", overwrite = TRUE)),
    "empty_dm"
  )
})
