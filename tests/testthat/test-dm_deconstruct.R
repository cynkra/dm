test_that("snapshot test", {
  expect_snapshot({
    dm <- dm_nycflights13()
    dm_deconstruct(dm)
  })
})

test_that("non-syntactic names", {
  expect_snapshot({
    dm <- dm(`if` = tibble(a = 1), `a b` = tibble(b = 1))
    dm_deconstruct(dm)
  })
})
