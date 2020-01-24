test_that("basic test: 'unite()'-methods work", {
  expect_identical(
    unite(zoomed_dm, "new_col", c, e) %>% get_zoomed_tbl(),
    unite(t2, "new_col", c, e)
  )

  expect_dm_error(
    unite(dm_for_filter),
    "only_possible_w_zoom"
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

  expect_dm_error(
    separate(dm_for_filter),
    "only_possible_w_zoom"
  )
})

test_that("key tracking works", {
  expect_identical(
    unite(zoomed_dm, "new_col", c, e) %>% dm_update_zoomed() %>% get_all_keys("t2"),
    set_names("d")
  )

  expect_identical(
    unite(zoomed_dm, "new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      get_all_keys("t2"),
    set_names(c("c", "d", "e"))
  )

  expect_identical(
    unite(zoomed_dm, "new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      dm_add_fk(t2, new_col, t6) %>%
      dm_zoom_to(t2) %>%
      separate(new_col, c("c", "e"), remove = TRUE) %>%
      dm_update_zoomed() %>%
      get_all_keys("t2"),
    set_names(c("c", "d", "e"))
  )

  expect_identical(
    unite(zoomed_dm, "new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      dm_add_fk(t2, new_col, t6) %>%
      dm_zoom_to(t2) %>%
      separate(new_col, c("c", "e"), remove = FALSE) %>%
      dm_update_zoomed() %>%
      get_all_keys("t2"),
    set_names(c("c", "d", "e", "new_col"))
  )
})
