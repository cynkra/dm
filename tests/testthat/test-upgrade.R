test_that("can upgrade from v1", {
  if (FALSE) {
    saveRDS(dm_for_filter(), "tests/testthat/dm/v1.rds", version = 2)
    saveRDS(dm_for_filter() |> dm_zoom_to(tf_2), "tests/testthat/dm/v1_zoomed.rds", version = 2)
  }

  dm_v1 <- readRDS(test_path("dm/v1.rds"))
  expect_silent(def <- dm_get_def(dm_v1, quiet = TRUE))
  expect_message(def <- dm_get_def(dm_v1))
  expect_silent(dm <- new_dm3(def))
  expect_silent(validate_dm(dm))
  expect_false(is_zoomed(dm))
})

test_that("can upgrade zoomed from v1", {
  dm_v1_zoomed <- readRDS(test_path("dm/v1_zoomed.rds"))
  expect_silent(def <- dm_get_def(dm_v1_zoomed, quiet = TRUE))
  expect_message(def <- dm_get_def(dm_v1_zoomed))
  expect_silent(dm <- new_dm3(def, zoomed = TRUE))
  expect_silent(validate_dm(dm))
  expect_true(is_zoomed(dm))
})
