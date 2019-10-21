bad_filtered_dm <- cdm_filter(bad_dm, tbl_1, a != 4)

test_that("`cdm_flatten_to_tbl()` does the right things for 'left_join()'", {
  # for left join test the basic flattening also on all DBs
  walk(
    dm_for_flatten_src,
    ~ expect_equal(
      cdm_flatten_to_tbl(., fact) %>% collect(),
      result_from_flatten)
  )

  # a one-table-dm
    expect_equivalent(
      dm_for_flatten %>%
        cdm_select_tbl(fact) %>%
        cdm_flatten_to_tbl(fact),
      fact
    )

  # explicitly choose parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_2),
    left_join(
      rename(fact, fact.something = something), rename(dim_1, dim_1.something = something),
      by = c("dim_1_key" = "dim_1_pk")) %>%
      left_join(rename(dim_2, dim_2.something = something), by = c("dim_2_key" = "dim_2_pk"))
  )

  # change order of parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1),
    left_join(
      rename(fact, fact.something = something), rename(dim_2, dim_2.something = something),
      by = c("dim_2_key" = "dim_2_pk")) %>%
      left_join(rename(dim_1, dim_1.something = something), by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    cdm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3),
    left_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      left_join(tbl_3, by = c("b" = "id"))
  )

  # filtered `dm`
  expect_identical(
    cdm_flatten_to_tbl(bad_filtered_dm, tbl_1),
    cdm_apply_filters(bad_filtered_dm) %>% cdm_flatten_to_tbl(tbl_1)
  )

  # with grandparent table
  expect_error(
    cdm_flatten_to_tbl(dm_more_complex, t5, t4, t3),
    class = cdm_error("only_parents")
  )

  # table unreachable
  expect_error(
    cdm_flatten_to_tbl(dm_for_filter, t2, t3, t4),
    class = cdm_error("tables_not_reachable_from_start")
  )

  # deeper hierarchy available and `auto_detect = TRUE`
  # for flatten: columns from t5 + t4 + t4_2 + t6 are combined in one table, 8 cols in total
  expect_identical(
    length(colnames(cdm_flatten_to_tbl(dm_more_complex, t5))),
    8L
  )

})

test_that("`cdm_flatten_to_tbl()` does the right things for 'inner_join()'", {
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, join = inner_join),
    result_from_flatten
  )

  # explicitly choose parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_2, join = inner_join),
    inner_join(
      rename(fact, fact.something = something), rename(dim_1, dim_1.something = something),
      by = c("dim_1_key" = "dim_1_pk")) %>%
      inner_join(rename(dim_2, dim_2.something = something), by = c("dim_2_key" = "dim_2_pk"))
  )

  # change order of parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1, join = inner_join),
    inner_join(
      rename(fact, fact.something = something), rename(dim_2, dim_2.something = something),
      by = c("dim_2_key" = "dim_2_pk")) %>%
      inner_join(rename(dim_1, dim_1.something = something), by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    cdm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3, join = inner_join),
    inner_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      inner_join(tbl_3, by = c("b" = "id"))
  )

  # filtered `dm`
  expect_identical(
    cdm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = inner_join),
    cdm_apply_filters(bad_filtered_dm) %>% cdm_flatten_to_tbl(tbl_1, join = inner_join)
  )

})

test_that("`cdm_flatten_to_tbl()` does the right things for 'full_join()'", {
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, join = full_join),
    full_join(fact_clean, dim_1_clean, by = c("dim_1_key" = "dim_1_pk")) %>%
      full_join(dim_2_clean, by = c("dim_2_key" = "dim_2_pk")) %>%
      full_join(dim_3_clean, by = c("dim_3_key" = "dim_3_pk")) %>%
      full_join(dim_4_clean, by = c("dim_4_key" = "dim_4_pk"))
  )

  # explicitly choose parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_2, join = full_join),
    full_join(
      rename(fact, fact.something = something), rename(dim_1, dim_1.something = something),
      by = c("dim_1_key" = "dim_1_pk")) %>%
      full_join(rename(dim_2, dim_2.something = something), by = c("dim_2_key" = "dim_2_pk"))
  )

  # change order of parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1, join = full_join),
    full_join(
      rename(fact, fact.something = something), rename(dim_2, dim_2.something = something),
      by = c("dim_2_key" = "dim_2_pk")) %>%
      full_join(rename(dim_1, dim_1.something = something), by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    cdm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3, join = full_join),
    full_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      full_join(tbl_3, by = c("b" = "id"))
  )

  # filtered `dm`
  expect_error(
    cdm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = full_join),
    class = cdm_error(c("apply_filters_first_full_join", "apply_filters_first"))
  )
})

test_that("`cdm_flatten_to_tbl()` does the right things for 'semi_join()'", {
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, join = semi_join),
    fact
  )

  # explicitly choose parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_2, join = semi_join),
    semi_join(fact, dim_1, by = c("dim_1_key" = "dim_1_pk")) %>%
      semi_join(dim_2, by = c("dim_2_key" = "dim_2_pk"))
  )

  # change order of parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1, join = semi_join),
    semi_join(fact, dim_2, by = c("dim_2_key" = "dim_2_pk")) %>%
      semi_join(dim_1, by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    cdm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3, join = semi_join),
    semi_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      semi_join(tbl_3, by = c("b" = "id"))
  )

  # filtered `dm`
  expect_identical(
    cdm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = semi_join),
    cdm_apply_filters(bad_filtered_dm) %>% cdm_flatten_to_tbl(tbl_1, join = semi_join)
  )
})

test_that("`cdm_flatten_to_tbl()` does the right things for 'anti_join()'", {
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, join = anti_join),
    fact %>% filter(1 == 0)
  )

  # explicitly choose parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_2, join = anti_join),
    anti_join(fact, dim_1, by = c("dim_1_key" = "dim_1_pk")) %>%
      anti_join(dim_2, by = c("dim_2_key" = "dim_2_pk"))
  )

  # change order of parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1, join = anti_join),
    anti_join(fact, dim_2, by = c("dim_2_key" = "dim_2_pk")) %>%
      anti_join(dim_1, by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    cdm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3, join = anti_join),
    anti_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      anti_join(tbl_3, by = c("b" = "id"))
  )

  # filtered `dm`
  expect_identical(
    cdm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = anti_join),
    cdm_apply_filters(bad_filtered_dm) %>% cdm_flatten_to_tbl(tbl_1, join = anti_join)
  )
})

test_that("`cdm_flatten_to_tbl()` does the right things for 'nest_join()'", {
  expect_error(
    cdm_flatten_to_tbl(dm_for_flatten, fact, join = nest_join),
    "nest_join",
    class = cdm_error("no_flatten_with_nest_join")
  )

})


test_that("`cdm_flatten_to_tbl()` does the right things for 'right_join()'", {
  expect_identical(
    expect_warning(
      cdm_flatten_to_tbl(dm_for_flatten, fact, join = right_join),
      "right_join()"),
    right_join(fact_clean, dim_1_clean, by = c("dim_1_key" = "dim_1_pk")) %>%
      right_join(dim_2_clean, by = c("dim_2_key" = "dim_2_pk")) %>%
      right_join(dim_3_clean, by = c("dim_3_key" = "dim_3_pk")) %>%
      right_join(dim_4_clean, by = c("dim_4_key" = "dim_4_pk"))
  )

  # explicitly choose parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_2, join = right_join),
    right_join(
      rename(fact, fact.something = something), rename(dim_1, dim_1.something = something),
      by = c("dim_1_key" = "dim_1_pk")) %>%
      right_join(rename(dim_2, dim_2.something = something), by = c("dim_2_key" = "dim_2_pk"))
  )

  # change order of parent tables
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1, join = right_join),
    right_join(
      rename(fact, fact.something = something), rename(dim_2, dim_2.something = something),
      by = c("dim_2_key" = "dim_2_pk")) %>%
      right_join(rename(dim_1, dim_1.something = something), by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    cdm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3, join = right_join),
    right_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      right_join(tbl_3, by = c("b" = "id"))
  )

  # flatten bad_dm (no referential integrity); different order
  expect_identical(
    cdm_flatten_to_tbl(bad_dm, tbl_1, tbl_3, tbl_2, join = right_join),
    right_join(tbl_1, tbl_3, by = c("b" = "id")) %>%
      right_join(tbl_2, by = c("a" = "id"))
  )

  # filtered `dm`
  expect_error(
    cdm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = right_join),
    class = cdm_error(c("apply_filters_first_right_join", "apply_filters_first"))
  )
})

test_that("`cdm_squash_to_tbl()` does the right things", {
  # with grandparent table
  # left_join:
  expect_identical(
    cdm_squash_to_tbl(dm_more_complex, t5, t4, t3),
    left_join(t5, t4, by = c("l" = "h")) %>%
      left_join(t3, by = c("j" = "f"))
    )

  # deeper hierarchy available and `auto_detect = TRUE`
  # for flatten: columns from t5 + t4 + t3 + t4_2 + t6 are combined in one table, 9 cols in total
  expect_identical(
    length(colnames(cdm_squash_to_tbl(dm_more_complex, t5))),
    9L
  )

  # full_join:
  expect_identical(
    cdm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = full_join),
    full_join(t5, t4, by = c("l" = "h")) %>%
      full_join(t3, by = c("j" = "f"))
    )

  # inner_join:
  expect_identical(
    cdm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = inner_join),
    inner_join(t5, t4, by = c("l" = "h")) %>%
      inner_join(t3, by = c("j" = "f"))
    )

  # right_join:
  expect_error(
    cdm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = right_join),
    "`left_join`, `inner_join`, `full_join`",
    class = cdm_error("squash_limited")
  )

  # semi_join:
  expect_error(
    cdm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = semi_join),
    "`left_join`, `inner_join`, `full_join`",
    class = cdm_error("squash_limited")
  )

  # anti_join:
  expect_error(
    cdm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = anti_join),
    "`left_join`, `inner_join`, `full_join`",
    class = cdm_error("squash_limited")
  )
})

test_that("prepare_dm_for_flatten() works", {
  # unfiltered with rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(dm_for_flatten, c("fact", "dim_1", "dim_3"), gotta_rename = TRUE),
    cdm_select_tbl(dm_for_flatten, fact, dim_1, dim_3) %>% cdm_disambiguate_cols(quiet = TRUE)
  )

  # filtered with rename
  red_dm <- cdm_select_tbl(dm_for_flatten, fact, dim_1, dim_3)
  tables <- cdm_get_tables(red_dm)
  tables[["fact"]] <- filter(tables[["fact"]], dim_1_key > 7)

  def <- cdm_get_def(red_dm)
  def$data <- tables
  prep_dm <- new_dm3(def)
  prep_dm_renamed <- cdm_disambiguate_cols(prep_dm, quiet = TRUE)

  expect_equivalent_dm(
    prepare_dm_for_flatten(
      cdm_filter(dm_for_flatten, dim_1, dim_1_pk > 7),
      c("fact", "dim_1", "dim_3"),
      gotta_rename = TRUE
    ),
    prep_dm_renamed
  )

  # filtered without rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(
      cdm_filter(dm_for_flatten, dim_1, dim_1_pk > 7),
      c("fact", "dim_1", "dim_3"),
      gotta_rename = FALSE
    ),
    prep_dm
  )

  # unfiltered without rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(dm_for_flatten, c("fact", "dim_1", "dim_3"), gotta_rename = FALSE),
    cdm_select_tbl(dm_for_flatten, fact, dim_1, dim_3)
  )
})
