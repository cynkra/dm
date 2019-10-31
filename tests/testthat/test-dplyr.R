zoomed_dm <- cdm_zoom_to_tbl(dm_for_filter, t2)

test_that("'group_by()'-methods work", {
  expect_identical(
    group_by(zoomed_dm, e) %>% get_zoomed_tbl(),
    group_by(t2, e)
  )

  expect_cdm_error(
    group_by(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})
