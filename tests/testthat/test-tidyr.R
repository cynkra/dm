test_that("basic test: 'unite()'-methods work", {
  expect_identical(
    unite(zoomed_dm, "new_col", c, e) %>% get_zoomed_tbl(),
    unite(t2, "new_col", c, e)
  )

  expect_cdm_error(
    unite(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'separate()'-methods work", {
  expect_identical(
    unite(zoomed_dm, "new_col", c, e) %>%
      separate("new_col", c("c", "e")) %>%
      select(c, d, e) %>%
      get_zoomed_tbl(),
    t2
  )

  expect_cdm_error(
    separate(dm_for_filter),
    "no_table_zoomed_dplyr"
  )

})

test_that("key tracking works", {
  expect_identical(
    unite(zoomed_dm, "new_col", c, e) %>% cdm_update_zoomed_tbl() %>% get_all_keys("t2"),
    set_names("d")
  )

  expect_identical(
    unite(zoomed_dm, "new_col", c, e, remove = FALSE) %>%
      cdm_update_zoomed_tbl() %>%
      get_all_keys("t2"),
    set_names(c("c", "d", "e"))
  )

  expect_identical(
    unite(zoomed_dm, "new_col", c, e, remove = FALSE) %>%
      cdm_update_zoomed_tbl() %>%
      cdm_add_fk(t2, new_col, t6) %>%
      cdm_zoom_to_tbl(t2) %>%
      separate(new_col, c("c", "e"), remove = TRUE) %>%
      cdm_update_zoomed_tbl() %>%
      get_all_keys("t2"),
    set_names(c("c", "d", "e"))
  )

  expect_identical(
    unite(zoomed_dm, "new_col", c, e, remove = FALSE) %>%
      cdm_update_zoomed_tbl() %>%
      cdm_add_fk(t2, new_col, t6) %>%
      cdm_zoom_to_tbl(t2) %>%
      separate(new_col, c("c", "e"), remove = FALSE) %>%
      cdm_update_zoomed_tbl() %>%
      get_all_keys("t2"),
    set_names(c("c", "d", "e", "new_col"))
  )
})
