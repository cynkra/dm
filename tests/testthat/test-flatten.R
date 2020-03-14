bad_filtered_dm <- dm_filter(bad_dm, tbl_1, a != 4)

test_that("`dm_flatten_to_tbl()` does the right things for 'left_join()'", {
  # for left join test the basic flattening also on all DBs
  walk(
    dm_for_flatten_src,
    ~ expect_equal(
      dm_flatten_to_tbl(., fact) %>% collect(),
      result_from_flatten
    )
  )

  # a one-table-dm
  expect_equivalent(
    dm_for_flatten %>%
      dm_select_tbl(fact) %>%
      dm_flatten_to_tbl(fact),
    fact
  )

  # explicitly choose parent tables
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_2),
    left_join(
      rename(fact, fact.something = something), rename(dim_1, dim_1.something = something),
      by = c("dim_1_key" = "dim_1_pk")
    ) %>%
      left_join(rename(dim_2, dim_2.something = something), by = c("dim_2_key" = "dim_2_pk"))
  )

  # change order of parent tables
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1),
    left_join(
      rename(fact, fact.something = something), rename(dim_2, dim_2.something = something),
      by = c("dim_2_key" = "dim_2_pk")
    ) %>%
      left_join(rename(dim_1, dim_1.something = something), by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    dm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3),
    left_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      left_join(tbl_3, by = c("b" = "id"))
  )

  # filtered `dm`
  expect_identical(
    dm_flatten_to_tbl(bad_filtered_dm, tbl_1),
    dm_apply_filters(bad_filtered_dm) %>% dm_flatten_to_tbl(tbl_1)
  )

  # with grandparent table
  expect_dm_error(
    dm_flatten_to_tbl(dm_more_complex, t5, t4, t3),
    class = "only_parents"
  )

  # table unreachable
  expect_dm_error(
    dm_flatten_to_tbl(dm_for_filter, t2, t3, t4),
    class = "tables_not_reachable_from_start"
  )

  # deeper hierarchy available and `auto_detect = TRUE`
  # for flatten: columns from t5 + t4 + t4_2 + t6 are combined in one table, 8 cols in total
  # FIXME: expect_length(...)
  expect_identical(
    length(colnames(dm_flatten_to_tbl(dm_more_complex, t5))),
    8L
  )
})

test_that("`dm_flatten_to_tbl()` does the right things for 'inner_join()'", {
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, join = inner_join),
    result_from_flatten
  )
})

test_that("`dm_flatten_to_tbl()` does the right things for 'full_join()'", {
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, join = full_join),
    full_join(fact_clean, dim_1_clean, by = c("dim_1_key" = "dim_1_pk")) %>%
      full_join(dim_2_clean, by = c("dim_2_key" = "dim_2_pk")) %>%
      full_join(dim_3_clean, by = c("dim_3_key" = "dim_3_pk")) %>%
      full_join(dim_4_clean, by = c("dim_4_key" = "dim_4_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    dm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3, join = full_join),
    full_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      full_join(tbl_3, by = c("b" = "id"))
  )

  # filtered `dm`
  expect_dm_error(
    dm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = full_join),
    class = c("apply_filters_first_full_join", "apply_filters_first")
  )
})

test_that("`dm_flatten_to_tbl()` does the right things for 'semi_join()'", {
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, join = semi_join),
    fact
  )

  # filtered `dm`
  expect_identical(
    dm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = semi_join),
    dm_apply_filters(bad_filtered_dm) %>% dm_flatten_to_tbl(tbl_1, join = semi_join)
  )
})

test_that("`dm_flatten_to_tbl()` does the right things for 'anti_join()'", {
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, join = anti_join),
    fact %>% filter(1 == 0)
  )
})

test_that("`dm_flatten_to_tbl()` does the right things for 'nest_join()'", {
  expect_dm_error(
    dm_flatten_to_tbl(dm_for_flatten, fact, join = nest_join),
    class = "no_flatten_with_nest_join"
  )
})


test_that("`dm_flatten_to_tbl()` does the right things for 'right_join()'", {
  expect_identical(
    expect_warning(
      dm_flatten_to_tbl(dm_for_flatten, fact, join = right_join),
      "right_join()"
    ),
    right_join(fact_clean, dim_1_clean, by = c("dim_1_key" = "dim_1_pk")) %>%
      right_join(dim_2_clean, by = c("dim_2_key" = "dim_2_pk")) %>%
      right_join(dim_3_clean, by = c("dim_3_key" = "dim_3_pk")) %>%
      right_join(dim_4_clean, by = c("dim_4_key" = "dim_4_pk"))
  )

  # change order of parent tables
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, dim_2, dim_1, join = right_join),
    right_join(
      rename(fact, fact.something = something), rename(dim_2, dim_2.something = something),
      by = c("dim_2_key" = "dim_2_pk")
    ) %>%
      right_join(rename(dim_1, dim_1.something = something), by = c("dim_1_key" = "dim_1_pk"))
  )

  # flatten bad_dm (no referential integrity)
  expect_identical(
    dm_flatten_to_tbl(bad_dm, tbl_1, tbl_2, tbl_3, join = right_join),
    right_join(tbl_1, tbl_2, by = c("a" = "id")) %>%
      right_join(tbl_3, by = c("b" = "id"))
  )

  # flatten bad_dm (no referential integrity); different order
  expect_identical(
    dm_flatten_to_tbl(bad_dm, tbl_1, tbl_3, tbl_2, join = right_join),
    right_join(tbl_1, tbl_3, by = c("b" = "id")) %>%
      right_join(tbl_2, by = c("a" = "id"))
  )

  # filtered `dm`
  expect_dm_error(
    dm_flatten_to_tbl(bad_filtered_dm, tbl_1, join = right_join),
    class = c("apply_filters_first_right_join", "apply_filters_first")
  )

  # fails when there is a cycle
  expect_dm_error(
    dm_nycflights_small %>%
      dm_add_fk(flights, origin, airports) %>%
      dm_flatten_to_tbl(flights),
    "no_cycles"
  )
})

test_that("`dm_squash_to_tbl()` does the right things", {
  # with grandparent table
  # left_join:
  expect_identical(
    dm_squash_to_tbl(dm_more_complex, t5, t4, t3),
    left_join(t5, t4, by = c("l" = "h")) %>%
      left_join(t3, by = c("j" = "f"))
  )

  # deeper hierarchy available and `auto_detect = TRUE`
  # for flatten: columns from t5 + t4 + t3 + t4_2 + t6 are combined in one table, 9 cols in total
  # FIXME: expect_length(...)
  expect_identical(
    length(colnames(dm_squash_to_tbl(dm_more_complex, t5))),
    9L
  )

  # full_join:
  expect_identical(
    dm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = full_join),
    full_join(t5, t4, by = c("l" = "h")) %>%
      full_join(t3, by = c("j" = "f"))
  )

  # skipping inner_join, not gaining new info

  # right_join:
  expect_dm_error(
    dm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = right_join),
    class = "squash_limited"
  )

  # semi_join:
  expect_dm_error(
    dm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = semi_join),
    class = "squash_limited"
  )

  # anti_join:
  expect_dm_error(
    dm_squash_to_tbl(dm_more_complex, t5, t4, t3, join = anti_join),
    class = "squash_limited"
  )

  # fails when there is a cycle:
  expect_dm_error(
    dm_squash_to_tbl(dm_for_filter_w_cycle, t5),
    "no_cycles"
  )
})

test_that("prepare_dm_for_flatten() works", {
  # unfiltered with rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(dm_for_flatten, c("fact", "dim_1", "dim_3"), gotta_rename = TRUE),
    dm_select_tbl(dm_for_flatten, fact, dim_1, dim_3) %>% dm_disambiguate_cols(quiet = TRUE)
  )

  # filtered with rename
  red_dm <- dm_select_tbl(dm_for_flatten, fact, dim_1, dim_3)
  tables <- dm_get_tables_impl(red_dm)
  tables[["fact"]] <- filter(tables[["fact"]], dim_1_key > 7)
  tables[["dim_1"]] <- filter(tables[["dim_1"]], dim_1_pk > 7)

  def <- dm_get_def(red_dm)
  def$data <- tables
  prep_dm <- new_dm3(def)
  prep_dm_renamed <- dm_disambiguate_cols(prep_dm, quiet = TRUE)

  expect_equivalent_dm(
    prepare_dm_for_flatten(
      dm_filter(dm_for_flatten, dim_1, dim_1_pk > 7),
      c("fact", "dim_1", "dim_3"),
      gotta_rename = TRUE
    ),
    prep_dm_renamed
  )

  # filtered without rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(
      dm_filter(dm_for_flatten, dim_1, dim_1_pk > 7),
      c("fact", "dim_1", "dim_3"),
      gotta_rename = FALSE
    ),
    prep_dm
  )

  # unfiltered without rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(dm_for_flatten, c("fact", "dim_1", "dim_3"), gotta_rename = FALSE),
    dm_select_tbl(dm_for_flatten, fact, dim_1, dim_3)
  )
})

test_that("tidyselect works for flatten", {
  # test if deselecting works
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, -dim_2, dim_3, -dim_4, dim_1),
    dm_flatten_to_tbl(dm_for_flatten, fact, dim_1, dim_3)
  )

  # test if select helpers work
  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, ends_with("3"), ends_with("1")),
    dm_flatten_to_tbl(dm_for_flatten, fact, dim_3, dim_1)
  )

  expect_identical(
    dm_flatten_to_tbl(dm_for_flatten, fact, everything()),
    dm_flatten_to_tbl(dm_for_flatten, fact)
  )

  # if only deselecting one potential candidate for flattening, the tables that are not
  # candidates will generally be part of the choice
  expect_dm_error(
    dm_flatten_to_tbl(dm_for_filter, t2, -t1),
    class = "tables_not_reachable_from_start"
  )

  # trying to deselect table that doesn't exist:
  expect_error(
    dm_flatten_to_tbl(dm_for_filter, t2, -t101),
    class = "vctrs_error_subscript"
  )
})

test_that("`dm_join_to_tbl()` works", {
  expect_identical(
    expect_message(dm_join_to_tbl(dm_for_flatten, fact, dim_3), "Renamed"),
    left_join(
      rename(fact, fact.something = something),
      rename(dim_3, dim_3.something = something),
      by = c("dim_3_key" = "dim_3_pk")
    )
  )

  expect_dm_error(
    dm_join_to_tbl(dm_for_filter, t7, t8),
    "table_not_in_dm"
  )
})
