test_that("`json_nest()` works", {
  expect_snapshot({
    df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
    nested <- json_nest(df, data = c(y, z))
    nested
  })
})

test_that("`json_nest()` works remotely", {
  # FIXME: add "mssql" when ready
  skip_if_src_not("postgres")
  con <- my_test_src()$con

  withr::defer(
    try(dbExecute(con, "DROP TABLE iris"))
  )

  dbWriteTable(con, "iris", iris)
  iris_remote <- tbl(con, "iris")

  expect_snapshot({
    json_nest(iris_remote, Sepal = 1:2, Petal = starts_with("Petal"))
    json_nest(iris_remote, Sepal = 1:2, Petal = starts_with("Petal"), .names_sep = ".")
  })
})
