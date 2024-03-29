withr::local_seed(20220706)

test_that("waldo", {
  skip_if_not_installed("waldo", "0.3.0")

  dm <- dm_nycflights13()

  expect_snapshot({
    dm %>%
      waldo::compare(dm, max_diffs = 10)
  })
  expect_snapshot({
    dm %>%
      dm_select_tbl(-airlines) %>%
      waldo::compare(dm, max_diffs = 10)
  })
  expect_snapshot({
    dm %>%
      dm_select(airlines, -name) %>%
      waldo::compare(dm, max_diffs = 10)
  })
  expect_snapshot({
    dm %>%
      dm_rm_fk() %>%
      waldo::compare(dm, max_diffs = 10)
  })
  expect_snapshot({
    dm %>%
      dm_rm_pk() %>%
      waldo::compare(dm, max_diffs = 10)
  })
  expect_snapshot({
    dm %>%
      dm_set_colors("yellow" = flights) %>%
      waldo::compare(dm, max_diffs = 10)
  })
  expect_snapshot({
    dm %>%
      dm_zoom_to(flights) %>%
      waldo::compare(dm, max_diffs = 10)
  })
})
