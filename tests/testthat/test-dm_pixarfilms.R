test_that("`dm_pixarfilms()` works", {
  expect_snapshot(
    dm_examine_constraints(dm_pixarfilms(consistent = FALSE))
  )
  expect_snapshot(
    dm_examine_constraints(dm_pixarfilms(consistent = TRUE))
  )
})

test_that("`dm_pixarfilms()` version argument works", {
  dm_v1 <- dm_pixarfilms(version = "v1")
  expect_s3_class(dm_v1, "dm")
  expect_identical(dm_get_tables(dm_v1)$pixar_films, pixarfilms_v1()$pixar_films)

  dm_latest <- dm_pixarfilms(version = "latest")
  expect_s3_class(dm_latest, "dm")
  expect_identical(dm_get_tables(dm_latest)$pixar_films, pixarfilms::pixar_films)
})
