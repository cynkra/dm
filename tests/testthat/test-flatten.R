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
    # yet, here we eventually use `left_join()` anyway
    dm_for_flatten_src,
    ~ expect_equivalent(
      cdm_flatten_to_tbl(cdm_filter(.x, dim_1, dim_1_pk > 4), fact, dim_1, join = right_join) %>% collect(),
      left_join(fact, filter(dim_1, dim_1_pk > 4), by = c("dim_1_key" = "dim_1_pk")) %>%
        rename(fact.something = something.x, dim_1.something = something.y)
    )
  )

  map(
    # sqlite: RIGHT and FULL OUTER JOINs are not currently supported
    # yet, here we eventually use `left_join()` anyway
    dm_for_flatten_src,
    ~ expect_equivalent(
      cdm_flatten_to_tbl(cdm_filter(.x, fact, something > 4), fact, dim_1, join = right_join) %>% collect(),
      left_join(filter(fact, something > 4), dim_1, by = c("dim_1_key" = "dim_1_pk")) %>%
        rename(fact.something = something.x, dim_1.something = something.y)
    )
  )

  map(
    # sqlite: RIGHT and FULL OUTER JOINs are not currently supported
    # yet, here we eventually use `left_join()` anyway
    dm_for_flatten_src,
    ~ expect_equivalent(
      cdm_flatten_to_tbl(cdm_filter(.x, fact, something > 4), fact, join = right_join) %>% collect(),
      left_join(filter(fact, something > 4), dim_1, by = c("dim_1_key" = "dim_1_pk")) %>%
        rename(fact.something = something.x, dim_1.something = something.y) %>%
        left_join(rename(dim_2, dim_2.something = something), by = c("dim_2_key" = "dim_2_pk")) %>%
        left_join(rename(dim_3, dim_3.something = something), by = c("dim_3_key" = "dim_3_pk")) %>%
        left_join(rename(dim_4, dim_4.something = something), by = c("dim_4_key" = "dim_4_pk"))
    )
  )


})

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
      semi_join(flights, airlines, by = "carrier") %>%
        semi_join(airports, by = c("dest" = "faa")) %>%
        semi_join(planes, by = "tailnum")
    )

    expect_equivalent(
      cdm_flatten_to_tbl(
        cdm_nycflights13(cycle = TRUE) %>%
          cdm_rm_fk(flights, origin, airports),
        flights, airlines, join = semi_join),
      semi_join(flights, airlines, by = "carrier")
    )

  })

