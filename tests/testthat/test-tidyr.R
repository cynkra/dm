test_that("basic test: 'unite()'-methods work", {
  # see issue #361
  skip_if_remote_src()
  expect_equivalent_tbl(
    unite(zoomed_dm(), "new_col", c, e) %>% get_zoomed_tbl(),
    unite(tf_2(), "new_col", c, e)
  )

  expect_dm_error(
    unite(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'separate()'-methods work", {
  skip_if_remote_src()
  expect_equivalent_tbl(
    zoomed_dm() %>%
      unite("new_col", c, e) %>%
      separate("new_col", c("c", "e")) %>%
      select(c, d, e) %>%
      get_zoomed_tbl(),
    tf_2()
  )

  expect_dm_error(
    separate(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("key tracking works", {
  skip_if_remote_src()
  expect_identical(
    zoomed_dm() %>%
      unite("new_col", c, e) %>%
      dm_update_zoomed() %>%
      get_all_keys("tf_2"),
    new_keys("d")
  )

  expect_identical(
    zoomed_dm() %>%
      unite("new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      get_all_keys("tf_2"),
    new_keys(c("c", "d", "e"))
  )

  expect_identical(
    zoomed_dm() %>%
      unite("new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      dm_add_fk(tf_2, new_col, tf_6) %>%
      dm_zoom_to(tf_2) %>%
      separate(new_col, c("c", "e"), remove = TRUE) %>%
      dm_update_zoomed() %>%
      get_all_keys("tf_2"),
    new_keys(c("c", "d", "e"))
  )

  expect_identical(
    zoomed_dm() %>%
      unite("new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      dm_add_fk(tf_2, new_col, tf_6) %>%
      dm_zoom_to(tf_2) %>%
      separate(new_col, c("c", "e"), remove = FALSE) %>%
      dm_update_zoomed() %>%
      get_all_keys("tf_2"),
    new_keys(c("c", "d", "e", "new_col"))
  )
})


# tests for compound keys -------------------------------------------------

test_that("output for compound keys", {
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  expect_snapshot({
    unite_weather_dm <-
      nyc_comp() %>%
      dm_zoom_to(weather) %>%
      mutate(chr_col = "airport") %>%
      unite("new_col", origin, chr_col) %>%
      dm_update_zoomed()
    unite_weather_dm %>% get_all_keys("flights")
    unite_weather_dm %>% get_all_keys("weather")
    unite_flights_dm <-
      nyc_comp() %>%
      dm_zoom_to(flights) %>%
      mutate(chr_col = "airport") %>%
      unite("new_col", origin, chr_col) %>%
      dm_update_zoomed()
    unite_flights_dm %>% get_all_keys("flights")
    unite_flights_dm %>% get_all_keys("weather")
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      separate(origin, c("o1", "o2"), sep = "^..", remove = TRUE) %>%
      dm_update_zoomed()
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      separate(origin, c("o1", "o2"), sep = "^..", remove = FALSE) %>%
      dm_update_zoomed()
  })
})
