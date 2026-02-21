dm_for_flatten_deep <- function() {
  dm(
    A = tibble::tibble(id = 1:3, b_id = 1:3, val_a = letters[1:3]),
    B = tibble::tibble(id = 1:3, c_id = 1:3, val_b = LETTERS[1:3]),
    C = tibble::tibble(id = 1:3, val_c = c("x", "y", "z"))
  ) %>%
    dm_add_pk(B, id) %>%
    dm_add_pk(C, id) %>%
    dm_add_fk(A, b_id, B) %>%
    dm_add_fk(B, c_id, C)
}

test_that("`dm_flatten()` works for basic star schema", {
  # Basic flatten: join all parents into fact
  result <- expect_message_obj(dm_flatten(dm_for_flatten(), fact))

  # Result should be a dm
  expect_s3_class(result, "dm")

  # fact should still exist
  expect_true("fact" %in% names(dm_get_tables(result)))

  # Parents should be removed
  expect_false("dim_1" %in% names(dm_get_tables(result)))
  expect_false("dim_2" %in% names(dm_get_tables(result)))
  expect_false("dim_3" %in% names(dm_get_tables(result)))
  expect_false("dim_4" %in% names(dm_get_tables(result)))

  # fact should have columns from parents (renamed for disambiguation)
  fact_result <- pull_tbl(result, fact)

  # The "something" column exists in all tables, so parents' should be renamed
  expect_true("something" %in% colnames(fact_result))
  expect_true("something.dim_1" %in% colnames(fact_result))
  expect_true("something.dim_2" %in% colnames(fact_result))
  expect_true("something.dim_3" %in% colnames(fact_result))
  expect_true("something.dim_4" %in% colnames(fact_result))

  # Result should have correct number of rows
  expect_equal(nrow(fact_result), nrow(fact()))
})

test_that("`dm_flatten()` snapshot with `dm_paste()`", {
  expect_snapshot({
    dm_flatten(dm_for_flatten(), fact) %>%
      dm_paste(options = c("select", "keys"))
  })

  expect_snapshot({
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("`dm_flatten()` recursive snapshot with `dm_paste()`", {
  expect_snapshot({
    dm_flatten(dm_more_complex(), tf_5, parent_tables = c(tf_4, tf_3), recursive = TRUE) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("`dm_flatten()` allow_deep snapshot with `dm_paste()`", {
  dm_deep <- dm_for_flatten_deep()

  expect_snapshot({
    dm_flatten(dm_deep, A, allow_deep = TRUE) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("`dm_flatten()` with no parents returns unchanged dm", {
  # A one-table dm
  one_tbl_dm <- dm_for_flatten() %>% dm_select_tbl(fact)
  result <- dm_flatten(one_tbl_dm, fact)
  expect_identical(names(dm_get_tables(result)), "fact")
  expect_equivalent_tbl(pull_tbl(result, fact), fact())
})

test_that("`dm_flatten()` with explicit parent selection", {
  # Flatten only dim_1 and dim_2
  result <- expect_message_obj(dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2)))

  expect_true("fact" %in% names(dm_get_tables(result)))
  expect_false("dim_1" %in% names(dm_get_tables(result)))
  expect_false("dim_2" %in% names(dm_get_tables(result)))
  # dim_3 and dim_4 should remain
  expect_true("dim_3" %in% names(dm_get_tables(result)))
  expect_true("dim_4" %in% names(dm_get_tables(result)))

  # fact should have columns from dim_1 and dim_2
  fact_result <- pull_tbl(result, fact)
  expect_true("something.dim_1" %in% colnames(fact_result))
  expect_true("something.dim_2" %in% colnames(fact_result))

  # FKs to dim_3 and dim_4 should still exist
  fks <- dm_get_all_fks(result)
  expect_true(any(fks$parent_table == "dim_3"))
  expect_true(any(fks$parent_table == "dim_4"))
})

test_that("`dm_flatten()` errors with deeper hierarchy by default", {
  expect_dm_error(
    dm_flatten(dm_more_complex(), tf_5, parent_tables = c(tf_4, tf_3)),
    class = "only_parents"
  )
})

test_that("`dm_flatten()` with recursive = TRUE works", {
  # dm_more_complex has tf_5 -> tf_4 -> tf_3
  result <- dm_flatten(dm_more_complex(), tf_5, parent_tables = c(tf_4, tf_3), recursive = TRUE)

  expect_s3_class(result, "dm")
  expect_true("tf_5" %in% names(dm_get_tables(result)))
  expect_false("tf_4" %in% names(dm_get_tables(result)))
  expect_false("tf_3" %in% names(dm_get_tables(result)))

  # tf_5 should have columns from tf_4 and tf_3
  tf5_result <- pull_tbl(result, tf_5)
  expected <-
    tf_5() %>%
    left_join(tf_4(), by = c("l" = "h")) %>%
    left_join(tf_3(), by = c("j" = "f", "j1" = "f1"))
  expect_equivalent_tbl(tf5_result, expected)
})

test_that("`dm_flatten()` with recursive = TRUE auto-detect", {
  result <- dm_flatten(dm_more_complex(), tf_5, recursive = TRUE)

  expect_s3_class(result, "dm")
  expect_true("tf_5" %in% names(dm_get_tables(result)))

  # All reachable ancestor tables should have been absorbed
  tf5_cols <- colnames(pull_tbl(result, tf_5))
  # tf_5 absorbs columns from tf_4, tf_3, tf_4_2, tf_6
  expect_true(length(tf5_cols) >= 10)
})

test_that("`dm_flatten()` with allow_deep = TRUE keeps grandparents", {
  dm_deep <- dm_for_flatten_deep()

  result <- dm_flatten(dm_deep, A, allow_deep = TRUE)

  # A should exist, B should be removed, C should remain
  expect_true("A" %in% names(dm_get_tables(result)))
  expect_false("B" %in% names(dm_get_tables(result)))
  expect_true("C" %in% names(dm_get_tables(result)))

  # A should have B's columns
  a_result <- pull_tbl(result, A)
  expect_true("val_b" %in% colnames(a_result))

  # FK from A to C should exist
  fks <- dm_get_all_fks(result)
  expect_true(any(fks$child_table == "A" & fks$parent_table == "C"))
})

test_that("`dm_flatten()` errors when recursive and allow_deep are both TRUE", {
  expect_dm_error(
    dm_flatten(dm_for_flatten(), fact, recursive = TRUE, allow_deep = TRUE),
    class = "recursive_and_allow_deep"
  )
})

test_that("`dm_flatten()` preserves primary keys of start table", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:3, parent_id = 1:3, val = letters[1:3]),
    parent = tibble::tibble(id = 1:3, info = LETTERS[1:3])
  ) %>%
    dm_add_pk(child, id) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, parent_id, parent)

  result <- dm_flatten(dm_test, child)

  # child's PK should be preserved
  pk <- dm_get_all_pks(result)
  expect_true(any(pk$table == "child"))
})

test_that("`dm_flatten()` with unreachable table errors", {
  expect_dm_error(
    dm_flatten(dm_for_filter(), tf_2, parent_tables = c(tf_3, tf_4)),
    class = "tables_not_reachable_from_start"
  )
})

test_that("`dm_flatten()` errors with cycles", {
  expect_dm_error(
    dm_flatten(
      dm_nycflights_small() %>%
        dm_add_fk(flights, origin, airports),
      flights
    ),
    "no_cycles"
  )
})

test_that("`dm_flatten()` with tidyselect via parent_tables", {
  # Deselection
  result1 <- expect_message_obj(
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(-dim_2, -dim_4))
  )
  result2 <- expect_message_obj(
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_3))
  )

  expect_equal(names(dm_get_tables(result1)), names(dm_get_tables(result2)))
  expect_equivalent_tbl(
    pull_tbl(result1, fact),
    pull_tbl(result2, fact)
  )

  # Select helpers
  result3 <- expect_message_obj(
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(ends_with("3"), ends_with("1")))
  )
  result4 <- expect_message_obj(
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_3, dim_1))
  )

  expect_equivalent_tbl(
    pull_tbl(result3, fact),
    pull_tbl(result4, fact)
  )
})

test_that("`dm_flatten()` handles column disambiguation correctly", {
  # All tables share "something" column
  result <- expect_message_obj(
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2))
  )

  fact_result <- pull_tbl(result, fact)
  # Start table keeps its "something" column name
  expect_true("something" %in% colnames(fact_result))
  # Parent columns get suffixed
  expect_true("something.dim_1" %in% colnames(fact_result))
  expect_true("something.dim_2" %in% colnames(fact_result))
})

test_that("`dm_flatten()` reports renames", {
  expect_message(
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2)),
    "Renaming"
  )
})

test_that("`dm_flatten()` errors on zoomed dm", {
  expect_dm_error(
    dm_for_flatten() %>% dm_zoom_to(fact) %>% dm_flatten(fact),
    class = "only_possible_wo_zoom"
  )
})
