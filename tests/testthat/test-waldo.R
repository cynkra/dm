test_that("waldo", {
  skip_if_not_installed("waldo", "0.3.0")
  expect_snapshot({
    dm_nycflights13() %>%
      waldo::compare(dm_nycflights13(), max_diffs = 10)
  })
  expect_snapshot({
    dm_nycflights13() %>%
      dm_select_tbl(-airlines) %>%
      waldo::compare(dm_nycflights13(), max_diffs = 10)
  })
  expect_snapshot({
    dm_nycflights13() %>%
      dm_select(airlines, -name) %>%
      waldo::compare(dm_nycflights13(), max_diffs = 10)
  })
  expect_snapshot({
    dm_nycflights13() %>%
      dm_rm_fk() %>%
      waldo::compare(dm_nycflights13(), max_diffs = 10)
  })
  expect_snapshot({
    dm_nycflights13() %>%
      dm_rm_pk(fail_fk = FALSE) %>%
      waldo::compare(dm_nycflights13(), max_diffs = 10)
  })
  expect_snapshot({
    dm_nycflights13() %>%
      dm_set_colors("yellow" = flights) %>%
      waldo::compare(dm_nycflights13(), max_diffs = 10)
  })
  expect_snapshot({
    dm_nycflights13() %>%
      dm_zoom_to(flights) %>%
      waldo::compare(dm_nycflights13(), max_diffs = 10)
  })
})
