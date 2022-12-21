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

test_that("can upgrade from v3", {
  if (FALSE) {
    # TODO:
    # - Run this code with a version of dm before the format change
    # - Search for attr(x, "version") and change
    saveRDS(dm_for_filter(), "tests/testthat/dm/v3.rds", version = 2)
    saveRDS(dm_for_filter() %>% dm_zoom_to(tf_2), "tests/testthat/dm/v3_zoomed.rds", version = 2)
  }

  dm_v3 <- readRDS(test_path("dm/v3.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v3, quiet = TRUE)
    def <- dm_get_def(dm_v3)
    dm <- new_dm3(def)
    dm_validate(dm)
    is_zoomed(dm)
  })
})

test_that("can upgrade zoomed from v3", {
  dm_v3_zoomed <- readRDS(test_path("dm/v3_zoomed.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v3_zoomed, quiet = TRUE)
    def <- dm_get_def(dm_v3_zoomed)
    dm <- new_dm3(def, zoomed = TRUE)
    dm_validate(dm)
    is_zoomed(dm)
  })
})

test_that("can upgrade to v4", {
  if (FALSE) {
    saveRDS(dm_for_filter(), "tests/testthat/dm/v4.rds", version = 2)
    saveRDS(dm_for_filter() %>% dm_zoom_to(tf_2), "tests/testthat/dm/v4_zoomed.rds", version = 2)
  }

  dm_v4 <- readRDS(test_path("dm/v4.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v4, quiet = TRUE)
    def <- dm_get_def(dm_v4)
    dm <- new_dm3(def)
    dm_validate(dm)
    is_zoomed(dm)
  })
})

test_that("can upgrade zoomed to v4", {
  dm_v4_zoomed <- readRDS(test_path("dm/v4_zoomed.rds"))
  expect_snapshot({
    def <- dm_get_def(dm_v4_zoomed, quiet = TRUE)
    def <- dm_get_def(dm_v4_zoomed)
    dm <- new_dm3(def, zoomed = TRUE)
    dm_validate(dm)
    is_zoomed(dm)
  })
})
