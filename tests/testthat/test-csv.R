test_that("dm_export_csv() writing csv files and handles missing directory", {

  x <- dm_nycflights13()

  ## path exists
  path <- file.path(tempdir(), "csvtest")
  dir.create(path)
  dm_export_csv(x, path=path)
  expect_equal(
    list.files(path),
    c("airlines.csv", "airports.csv", "flights.csv", "planes.csv", "weather.csv")
  )

  ## path not exists so will be created (recursively)
  path <- file.path(tempfile(), "csvtest")
  dm_export_csv(x, path=path)
  expect_equal(
    list.files(path),
    c("airlines.csv", "airports.csv", "flights.csv", "planes.csv", "weather.csv")
  )
})


test_that("dm_import_csv() read csv files into dm", {

  path <- file.path(tempdir(), "csvtest")
  dm_export_csv(dm_nycflights13(), path=path)

  dm <- dm_import_csv(path)
  expect_equal(
    names(dm),
    c("airlines", "airports", "flights", "planes", "weather")
  )
})
