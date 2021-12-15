test_that("build_copy_queries works", {
  src_db <- sqlite_test_src()
  expect_snapshot({
    dm_pixarfilms() %>%
      build_copy_queries(
        src_db,
        .
      )
  })
})
