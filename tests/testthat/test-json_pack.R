test_that("`json_pack()` works", {
  expect_snapshot({
    df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
    packed <- json_pack(df, x = c(x1, x2, x3), y = y)
    packed
  })
})

test_that("`json_pack()` works remotely", {
  # FIXME: add "mssql" when ready
  skip_if_src_not("postgres")
  con <- my_test_src()$con

  withr::defer(
    try(dbExecute(con, "DROP TABLE iris"))
  )

  dbWriteTable(con, "iris", iris)
  iris_remote <- tbl(con, "iris")

  expect_snapshot({
    json_pack(iris_remote, Sepal = 1:2, Petal = starts_with("Petal"))
    json_pack(iris_remote, Sepal = 1:2, Petal = starts_with("Petal"), .names_sep = ".")
  })
})
