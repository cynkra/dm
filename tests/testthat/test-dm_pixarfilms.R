test_that("`dm_pixarfilms()` works", {
  skip_if_not_installed("pixarfilms")

  expect_snapshot(
    dm_examine_constraints(dm_pixarfilms(consistent = FALSE))
  )
  expect_snapshot(
    dm_examine_constraints(dm_pixarfilms(consistent = TRUE))
  )
})
