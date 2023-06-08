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


test_that("dm_duckdb_csv() examples", {

  ## create exanple source data directory
  path <- file.path(tempdir(), "data")
  dir.create(path, showWarnings=FALSE)
  x <- dm_nycflights13()
  tbl_export_csv <- function(tbl, dm) {
    file <- file.path(path, paste(tbl, "csv", sep="."))
    utils::write.csv(dm[[tbl]], file=file, row.names=FALSE)
  }
  invisible(lapply(names(x), tbl_export_csv, x))
  expect_equal(
    list.files(path),
    c("airlines.csv", "airports.csv", "flights.csv", "planes.csv", "weather.csv")
  )

  ## create dm from remote csv files via duckdb
  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  d <- dm_duckdb_csv(path, conn)
  expect_true(inherits(d, "dm"))
  expect_equal(
    names(d),
    c("airlines", "airports", "flights", "planes", "weather")
  )

  ## cleanup db connection
  invisible(DBI::dbDisconnect(conn))
})

test_that("dm_duckdb_csv() handles partitioning", {
  ## 3 tables, 2 partitioned, one not
  path <- file.path(tempdir(), "data-partitioning")
  ## iris, partitioned by Species
  x <- split(datasets::iris, datasets::iris$Species)
  lapply(names(x), function(tbl) {
    file <- file.path(path, "iris", paste("Species", tbl, sep="="), "data.csv")
    dir.create(dirname(file), recursive=TRUE, showWarnings=FALSE)
    utils::write.csv(x[[tbl]], file=file, row.names=FALSE)
  })
  ## Titanic, partitioned by Sex
  ti <- as.data.frame(datasets::Titanic)
  x <- split(ti, ti$Sex)
  lapply(names(x), function(tbl) {
    file <- file.path(path, "titanic", paste("Sex", tbl, sep="="), "data.csv")
    dir.create(dirname(file), recursive=TRUE, showWarnings=FALSE)
    utils::write.csv(x[[tbl]], file=file, row.names=FALSE)
  })
  utils::write.csv(datasets::state.x77, file=file.path(path, "state.csv"), row.names=row.names(state.x77))
  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  d <- dm_duckdb_csv(path, conn)
  expect_true(inherits(d, "dm"))
  expect_equal(
    names(d),
    c("iris","state","titanic")
  )
  expect_equal(
    sapply(lapply(lapply(d, dplyr::count), collect), `[[`, "n"),
    c(iris=nrow(iris), state=nrow(state.x77), titanic=nrow(ti))
  )
  DBI::dbDisconnect(conn)
})

test_that("dm_duckdb_csv() handles nested partitioning", {
  ## 2 tables, 1 nested partitioned, one not
  path <- file.path(tempdir(), "data-nested-partitioning")
  ## Titanic, partitioned by Survived, Sex
  ti <- as.data.frame(datasets::Titanic)
  x <- lapply(split(ti, ti$Survived), function(y) split(y, y$Sex))
  lapply(names(x), function(sur) {
    lapply(names(x[[sur]]), function(sex) {
      file <- file.path(path, "titanic", paste("Survived", sur, sep="="), paste("Sex", sex, sep="="), "data.csv")
      dir.create(dirname(file), recursive=TRUE, showWarnings=FALSE)
      utils::write.csv(x[[sur]][[sex]], file=file, row.names=FALSE)
    })
  })
  utils::write.csv(datasets::state.x77, file=file.path(path, "state.csv"), row.names=row.names(state.x77))
  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  d <- dm_duckdb_csv(path, conn)
  expect_true(inherits(d, "dm"))
  expect_equal(
    names(d),
    c("state","titanic")
  )
  expect_equal(
    sapply(lapply(lapply(d, dplyr::count), collect), `[[`, "n"),
    c(state=nrow(state.x77), titanic=nrow(ti))
  )
  DBI::dbDisconnect(conn)
})

test_that("dm_duckdb_csv() handles mixed partitioning", {
  ## 3 tables, 1 partitioned, 1 nested partitioned, one not
  path <- file.path(tempdir(), "data-mixed-partitioning")
  ## iris, partitioned by Species
  x <- split(datasets::iris, datasets::iris$Species)
  lapply(names(x), function(tbl) {
    file <- file.path(path, "iris", paste("Species", tbl, sep="="), "data.csv")
    dir.create(dirname(file), recursive=TRUE, showWarnings=FALSE)
    utils::write.csv(x[[tbl]], file=file, row.names=FALSE)
  })
  ## Titanic, partitioned by Survived, Sex
  ti <- as.data.frame(datasets::Titanic)
  x <- lapply(split(ti, ti$Survived), function(y) split(y, y$Sex))
  lapply(names(x), function(sur) {
    lapply(names(x[[sur]]), function(sex) {
      file <- file.path(path, "titanic", paste("Survived", sur, sep="="), paste("Sex", sex, sep="="), "data.csv")
      dir.create(dirname(file), recursive=TRUE, showWarnings=FALSE)
      utils::write.csv(x[[sur]][[sex]], file=file, row.names=FALSE)
    })
  })
  utils::write.csv(datasets::state.x77, file=file.path(path, "state.csv"), row.names=row.names(state.x77))
  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  d <- dm_duckdb_csv(path, conn)
  expect_true(inherits(d, "dm"))
  expect_equal(
    names(d),
    c("iris","state","titanic")
  )
  expect_equal(
    sapply(lapply(lapply(d, dplyr::count), collect), `[[`, "n"),
    c(iris=nrow(iris), state=nrow(state.x77), titanic=nrow(ti))
  )
  DBI::dbDisconnect(conn)
})

test_that("dm_duckdb_csv() handles updates to data", {
  ## we technically dont update here but rewrite
  ## duckdb seems to not care about that
  ## so most likely does not hold open connection to file
  ## this could possibly change in future and then this test has to be updated to really update the file rather than rewrite it

  path <- file.path(tempdir(), "data-updates")
  dir.create(path, showWarnings=FALSE)
  df <- data.frame(a=1:2, b=3:4)
  file <- file.path(path, "data.csv")
  utils::write.csv(df, file=file, row.names=FALSE)
  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  d <- dm_duckdb_csv(path, conn)
  expect_equal(collect(d$data), tibble(a=1:2, b=3:4))
  df <- data.frame(a=c(1,20), b=3:4)
  utils::write.csv(df, file=file, row.names=FALSE)
  expect_equal(collect(d$data), tibble(a=c(1,20), b=3:4))

  invisible(DBI::dbDisconnect(conn))
})

test_that("dm_duckdb_csv() handles inserts to data", {

  path <- file.path(tempdir(), "data-inserts")
  dir.create(path, showWarnings=FALSE)
  df <- data.frame(a=1:2, b=3:4)
  file <- file.path(path, "data.csv")
  utils::write.csv(df, file=file, row.names=FALSE)
  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  d <- dm_duckdb_csv(path, conn)
  expect_identical(collect(dplyr::count(d$data))$n, 2)
  cat("3,6", file=file, append=TRUE)
  expect_identical(collect(dplyr::count(d$data))$n, 3)

  ## test inserting to partition
  ## TODO
  ## test inserting to new (non existing before) partition
  ## TODO

  invisible(DBI::dbDisconnect(conn))
})

test_that("dm_duckdb_csv() handles partitioned tables of 2+ csv files per partition", {

})

test_that("dm_duckdb_csv() errors for invalid input", {

})

test_that("dm_duckdb_csv() errors for invalid csv files structure", {

})
