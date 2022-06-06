test_that("error message for non-dm object", {
  # FIXME: Add a similar test to all callers of dm_get_def()
  expect_snapshot(error = TRUE, {
    dm_get_def(structure(list(table = "a"), class = "bogus"))
  })
})

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
    dm_validate(dm)
    is_zoomed(dm)
  })
})

test_that("can upgrade zoomed from v1", {
  dm_v1_zoomed <- readRDS(test_path("dm/v1_zoomed.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v1_zoomed, quiet = TRUE)
    def <- dm_get_def(dm_v1_zoomed)
    dm <- new_dm3(def, zoomed = TRUE)
    dm_validate(dm)
    is_zoomed(dm)
  })
})

test_that("can upgrade from v2", {
  if (FALSE) {
    saveRDS(dm_for_filter(), "tests/testthat/dm/v2.rds", version = 2)
    saveRDS(dm_for_filter() %>% dm_zoom_to(tf_2), "tests/testthat/dm/v2_zoomed.rds", version = 2)
  }

  dm_v2 <- readRDS(test_path("dm/v2.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v2, quiet = TRUE)
    def <- dm_get_def(dm_v2)
    dm <- new_dm3(def)
    dm_validate(dm)
    is_zoomed(dm)
  })
})

test_that("can upgrade zoomed from v2", {
  dm_v2_zoomed <- readRDS(test_path("dm/v2_zoomed.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v2_zoomed, quiet = TRUE)
    def <- dm_get_def(dm_v2_zoomed)
    dm <- new_dm3(def, zoomed = TRUE)
    dm_validate(dm)
    is_zoomed(dm)
  })
})
