test_that("can upgrade from v1", {
  if (FALSE) {
    saveRDS(dm_for_filter(), "tests/testthat/dm/v1.rds", version = 2)
    saveRDS(dm_for_filter() %>% dm_zoom_to(tf_2), "tests/testthat/dm/v1_zoomed.rds", version = 2)
  }

  dm_v1 <- readRDS(test_path("dm/v1.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v1, quiet = TRUE)
    def <- dm_get_def(dm_v1)
    dm <- new_dm3(def)
    validate_dm(dm)
    is_zoomed(dm)
  })
})

test_that("can upgrade zoomed from v1", {
  dm_v1_zoomed <- readRDS(test_path("dm/v1_zoomed.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v1_zoomed, quiet = TRUE)
    def <- dm_get_def(dm_v1_zoomed)
    dm <- new_dm3(def, zoomed = TRUE)
    validate_dm(dm)
    is_zoomed(dm)
  })
})
