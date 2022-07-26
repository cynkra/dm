test_that("snapshot test", {
  expect_snapshot({
    dm <- dm_nycflights13()
    dm_deconstruct(dm)
  })
})
