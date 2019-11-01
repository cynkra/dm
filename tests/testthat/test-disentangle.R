disentangled_flight_dm_src <-
  map(
    dm_nycflights_small_cycle_src,
    ~cdm_add_tbl(.,
      origin.airports = tbl(., "airports"),
      dest.airports = tbl(., "airports")) %>%
      cdm_select_tbl(flights, origin.airports, dest.airports, planes, airlines) %>%
      cdm_add_pk(origin.airports, faa) %>% cdm_add_pk(dest.airports, faa) %>%
      cdm_add_fk(flights, origin, origin.airports) %>% cdm_add_fk(flights, dest, dest.airports) %>%
      cdm_set_colors(origin.airports= , dest.airports = "orange")
  )

test_that("disentangling works", {
  walk2(
    dm_nycflights_small_cycle_src,
    disentangled_flight_dm_src,
    ~expect_equivalent_dm(
      cdm_disentangle(.x, flights),
      .y
      )
  )
})

test_that("disentangling doesn't do anything when not needed", {
  expect_equivalent_dm(
    cdm_disentangle(dm_for_filter, t2),
    dm_for_filter
  )
})
