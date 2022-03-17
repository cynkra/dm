test_that("dm_disentangle() works", {
  expect_snapshot({
    # using collect() cause otherwise the `src` is printed on DBs
    # nothing should happen if no cycles are detected
    dm_disentangle(dm_for_filter()) %>% collect()

    # disentangling for each graph component with a cycle
    dm_disentangle(dm_for_filter_w_cycle()) %>% collect()
    dm_disentangle(
      dm_bind(
        dm_for_disambiguate(),
        dm_for_filter_w_cycle(),
        dm_nycflights_small_cycle()
      )
    ) %>%
      dm_get_all_fks()
  })
})
