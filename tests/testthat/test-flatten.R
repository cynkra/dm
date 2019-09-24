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

test_that("`cdm_flatten_to_tbl()` does the right thing for filtered `dm`s", {

  walk(dm_more_complex_src,
       ~expect_equivalent(
         cdm_flatten_to_tbl(cdm_filter(., t1, a > 5), t5) %>% collect(),
         tibble(k = 2:4, l = letters[3:5], m = c("tree", rep("streetlamp", 2)),
                i = c("five", "six", "seven"), j = c("E", "F", "F"), g = c("four", rep("five", 2)),
                o = c("f", "h", "h"), s = i, t = c("E", "F", "G"))
       )
  )

  walk(dm_more_complex_src,
       ~expect_equivalent(
         cdm_flatten_to_tbl(cdm_filter(., t1, a > 5), t5, join = semi_join) %>% collect(),
         slice(t5, 2:4)
       )
  )

  walk(dm_more_complex_src,
       ~expect_equivalent(
         cdm_flatten_to_tbl(cdm_filter(., b, b_3 > 7), t5) %>% collect(),
         tibble(k = 1:4, l = letters[2:5], m = c("house", "tree", rep("streetlamp", 2)),
                i = c("four", "five", "six", "seven"), j = c("D", "E", "F", "F"),
                g = c("three", "four", rep("five", 2)), o = c("e", "f", "h", "h"),
                s = c("three", "five", "six", "seven"), t = c("D", "E", "F", "G"))
       )
  )

  # this is NYI for anti_join and semi_join:
  walk(dm_more_complex_src,
       ~expect_error(
         cdm_flatten_to_tbl(cdm_filter(., b, b_3 > 7), t5, join = semi_join) %>% collect(),
         class = cdm_error("semi_anti_nys")
       )
  )

})

test_that("`cdm_flatten_to_tbl()` throws right errors", {
  walk(dm_more_complex_src,
       ~expect_error(
         cdm_flatten_to_tbl(., t5, t6, t3),
         class = cdm_error("tables_not_reachable_from_start")
       )
  )

  walk(dm_for_filter_src,
       ~expect_error(
         cdm_flatten_to_tbl(., t5, join = right_join),
         class = cdm_error("rj_not_wd")
       )
  )
})
