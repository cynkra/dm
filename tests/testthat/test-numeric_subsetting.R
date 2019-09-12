test_that("numeric subsetting works", {

  # check specifically for the right output in one case
  expect_equal(dm_for_filter[[4]], t4)

  # compare numeric subsetting and subsetting by name on all sources
  walk(
    dm_for_filter_src,
    ~ expect_equal(
      .x[["t2"]],
      .x[[2]]
    )
  )

  # check if reducing `dm` size works on all sources
  walk(
    dm_for_filter_src,
    ~ expect_equal(
      .x[c(1, 3, 5)],
      cdm_select_tbl(.x, 1, 3, 5)
    )
  )
})
