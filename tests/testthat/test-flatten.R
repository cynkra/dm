test_that("`cdm_flatten_to_tbl()` does the right thing", {
  map(
    dm_for_flatten_src,
    ~ expect_equivalent(
      cdm_flatten_to_tbl(., fact) %>% collect(),
      result_from_flatten
    )
  )

  map(
    dm_for_flatten_src,
    ~ expect_equivalent(
      cdm_flatten_to_tbl(., fact, dim_1, dim_2) %>% collect(),
      left_join(
        rename(fact, fact.something = something), rename(dim_1, dim_1.something = something),
        by = c("dim_1_key" = "dim_1_pk")) %>%
        left_join(rename(dim_2, dim_2.something = something), by = c("dim_2_key" = "dim_2_pk"))
    )
  )
})

test_that("`cdm_flatten_to_tbl()` does the right thing for a one-table-dm", {
  map(
    dm_for_flatten_src,
    ~ expect_equivalent(
      cdm_flatten_to_tbl(cdm_select_tbl(., fact), fact) %>% collect(),
      fact
    )
  )
})

test_that("`cdm_flatten_to_tbl()` does the right thing for 'right_join()'", {
  map(
    # sqlite: RIGHT and FULL OUTER JOINs are not currently supported
    dm_for_flatten_src[setdiff(names(dm_for_flatten_src), "sqlite")],
    ~ expect_equivalent(
      cdm_flatten_to_tbl(cdm_filter(.x, dim_1, dim_1_pk > 4), fact, dim_1, join = right_join) %>% collect(),
      right_join(fact, filter(dim_1, dim_1_pk > 4), by = c("dim_1_key" = "dim_1_pk")) %>%
        rename(fact.something = something.x, dim_1.something = something.y)
    )
  )

  # It might be expected, that if the user choses a `right_join()`, `full_join()`, `semi_join()` or
  # `anti_join()`, he expects only the direct effect of filter conditions on dimension tables
  # to take an effect (so `dim_1, dim_1_pk > 4` has only an effect on table `dim_1` and no cascading effect);
  # that would mean, we'd need to sort the filter conditions by table and alter the `list_of_tables` accordingly
  #
  # this test depends on the answer to the above issue:
  # map(
  #   dm_for_flatten_src[setdiff(names(dm_for_flatten_src), "sqlite")],
  #   ~ expect_equivalent(
  #     cdm_flatten_to_tbl(cdm_filter(.x, fact, something > 4), fact, dim_1, join = right_join) %>% collect(),
  #     right_join(filter(fact, something > 4), dim_1, by = c("dim_1_key" = "dim_1_pk")) %>%
  #       rename(fact.something = something.x, dim_1.something = something.y)
  #   )
  # )

  test_that("`cdm_flatten_to_tbl()` does the right thing for 'anti_join()' and `semi_join()`", {

    expect_equivalent(
      cdm_flatten_to_tbl(
        cdm_nycflights13(cycle = TRUE) %>%
          cdm_rm_fk(flights, origin, airports),
        flights, airports, join = anti_join),
        anti_join(flights, airports, by = c("dest" = "faa"))
      )

    expect_equivalent(
      cdm_flatten_to_tbl(
        cdm_nycflights13(cycle = TRUE) %>%
          cdm_rm_fk(flights, origin, airports),
        flights, join = semi_join),
      semi_join(rename(flights, flights.year = year), rename(airlines, airlines.name = name), by = "carrier") %>%
        semi_join(rename(airports, airports.name = name), by = c("dest" = "faa")) %>%
        semi_join(rename(planes, planes.year = year), by = "tailnum")
    )

    expect_equivalent(
      cdm_flatten_to_tbl(
        cdm_nycflights13(cycle = TRUE) %>%
          cdm_rm_fk(flights, origin, airports),
        flights, airlines, join = semi_join),
      semi_join(flights, airlines, by = "carrier")
    )

  })
})
