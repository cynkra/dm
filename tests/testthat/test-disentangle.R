disentangled_flight_dm_src <-
  map(
    dm_nycflights_small_cycle_src,
    ~cdm_add_tbl(.,
      dest.airports = tbl(., "airports"),
      origin.airports = tbl(., "airports")) %>%
      cdm_select_tbl(flights, dest.airports, origin.airports, planes, airlines) %>%
      cdm_add_pk(origin.airports, faa) %>% cdm_add_pk(dest.airports, faa) %>%
      cdm_add_fk(flights, dest, dest.airports) %>%
      cdm_add_fk(flights, origin, origin.airports) %>%
      cdm_set_colors(origin.airports= , dest.airports = "orange")
  )

disentangled_entangled_dm <-
  as_dm(list(
    "first" = transmute(t4, j, other_j = j, another_j = j, and_one_more_j = j),
    "j.second" = t3,
    "other_j.second" = t3,
    "and_one_more_j.third" = t3,
    "another_j.third" = t3,
    "fourth" = transmute(t4, j, other_j = j),
    "j.fifth" = t3,
    "other_j.fifth" = t3,
    "id_ct" = transmute(t4, j),
    "id_pt" = t3)) %>%
  cdm_add_pk(j.second, f) %>%
  cdm_add_pk(other_j.second, f) %>%
  cdm_add_pk(and_one_more_j.third, f) %>%
  cdm_add_pk(another_j.third, f) %>%
  cdm_add_pk(j.fifth, f) %>%
  cdm_add_pk(other_j.fifth, f) %>%
  cdm_add_fk(first, j, j.second) %>%
  cdm_add_fk(first, other_j, other_j.second) %>%
  cdm_add_fk(first, another_j, another_j.third) %>%
  cdm_add_fk(first, and_one_more_j, and_one_more_j.third) %>%
  cdm_add_fk(fourth, j, j.fifth) %>%
  cdm_add_fk(fourth, other_j, other_j.fifth) %>%
  cdm_add_pk(id_pt, f) %>%
  cdm_add_fk(id_ct, j, id_pt) %>%
  cdm_set_colors(
    first = ,
    fourth = "blue",
    id_ct = ,
    id_pt = ,
    j.second = ,
    other_j.second = "orange",
    another_j.third = ,
    and_one_more_j.third = ,
    j.fifth = ,
    other_j.fifth = "green"
  )

test_that("disentangling works", {
  walk2(
    dm_nycflights_small_cycle_src,
    disentangled_flight_dm_src,
    ~expect_equivalent_dm(
      cdm_disentangle(.x),
      .y
      )
  )

  # much more entangled dm:
  expect_equivalent_dm(
    cdm_disentangle(entangled_dm),
    disentangled_entangled_dm
  )
})

test_that("disentangling doesn't do anything when not needed", {
  expect_equivalent_dm(
    cdm_disentangle(dm_for_filter),
    dm_for_filter
  )
})
