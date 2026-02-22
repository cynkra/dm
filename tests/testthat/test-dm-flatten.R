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
  expect_snapshot({
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(ends_with("3"), ends_with("1"))) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("`dm_flatten()` handles column disambiguation correctly", {
  expect_snapshot({
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("`dm_flatten()` reports renames", {
  expect_snapshot({
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("`dm_flatten()` errors on zoomed dm", {
  expect_dm_error(
    dm_for_flatten() %>% dm_zoom_to(fact) %>% dm_flatten(fact),
    class = "only_possible_wo_zoom"
  )
})

# --- Helper function tests ---

test_that("`dm_flatten_impl()` joins single parent without recursion", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:3, pid = 1:3, val = letters[1:3]),
    parent = tibble::tibble(id = 1:3, info = LETTERS[1:3])
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  out <- dm_flatten_impl(dm_test, "child", "parent", dfs_order = NULL, left_join)

  expect_s3_class(out$dm, "dm")
  expect_equal(names(dm_get_tables(out$dm)), "child")
  expect_true("info" %in% colnames(pull_tbl(out$dm, child)))
  expect_equal(out$all_renames, list())
})

test_that("`dm_flatten_impl()` recurses with dfs_order", {
  dm_deep <- dm_for_flatten_deep()

  g <- create_graph_from_dm(dm_deep, directed = TRUE)
  g_sub <- graph_induced_subgraph(g, c("A", "B", "C"))
  dfs <- graph_dfs(g_sub, "A", unreachable = FALSE, dist = TRUE)
  dfs_order <- names(dfs$order) %>% purrr::discard(is.na)

  out <- dm_flatten_impl(dm_deep, "A", c("B", "C"), dfs_order, left_join)

  expect_equal(names(dm_get_tables(out$dm)), "A")
  a_tbl <- pull_tbl(out$dm, A)
  expect_true("val_b" %in% colnames(a_tbl))
  expect_true("val_c" %in% colnames(a_tbl))
})

test_that("`dm_flatten_impl()` returns empty renames when no conflicts", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:2, pid = 1:2),
    parent = tibble::tibble(id = 1:2, extra = c("a", "b"))
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  out <- dm_flatten_impl(dm_test, "child", "parent", dfs_order = NULL, left_join)
  expect_equal(out$all_renames, list())
  expect_equal(out$col_renames, list(parent = character(0)))
})

test_that("`dm_flatten_join()` disambiguates conflicting columns", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:2, pid = 1:2, val = c("a", "b")),
    parent = tibble::tibble(id = 1:2, val = c("X", "Y"))
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  out <- dm_flatten_join(dm_test, "child", "parent", left_join)

  child_tbl <- pull_tbl(out$dm, child)
  expect_true("val" %in% colnames(child_tbl))
  expect_true("val.parent" %in% colnames(child_tbl))

  expect_length(out$all_renames, 1)
  expect_equal(out$all_renames[[1]]$table, "parent")
  expect_equal(out$all_renames[[1]]$renames, c(val = "val.parent"))
})

test_that("`dm_flatten_join()` returns col_renames for each parent", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:2, pid = 1:2, val = c("a", "b")),
    parent = tibble::tibble(id = 1:2, val = c("X", "Y"))
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  out <- dm_flatten_join(dm_test, "child", "parent", left_join)
  expect_true("parent" %in% names(out$col_renames))
  expect_equal(out$col_renames[["parent"]], c(val = "val.parent"))
})

test_that("`dm_flatten_join()` removes parent tables", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:2, pid = 1:2),
    parent = tibble::tibble(id = 1:2, extra = c("a", "b")),
    other = tibble::tibble(id = 1:2)
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  out <- dm_flatten_join(dm_test, "child", "parent", left_join)
  expect_equal(sort(names(dm_get_tables(out$dm))), c("child", "other"))
})

test_that("`dm_flatten_join()` with empty parents returns unchanged dm", {
  dm_test <- dm(child = tibble::tibble(id = 1:2))
  out <- dm_flatten_join(dm_test, "child", character(0), left_join)
  expect_equal(names(dm_get_tables(out$dm)), "child")
  expect_equal(out$all_renames, list())
  expect_equal(out$col_renames, list())
})

test_that("`dm_flatten_explain_renames()` produces message for renames", {
  renames <- list(
    list(table = "dim_1", renames = c(val = "val.dim_1"))
  )
  expect_message(dm_flatten_explain_renames(renames), "Renaming")
})

test_that("`dm_flatten_explain_renames()` is silent when no renames", {
  expect_silent(dm_flatten_explain_renames(list()))
})

test_that("`dm_flatten_transfer_fks()` re-points FKs to start table", {
  dm_deep <- dm_for_flatten_deep()
  all_fks <- dm_get_all_fks_impl(dm_deep, ignore_on_delete = TRUE)

  # Simulate: join B into A, remove B
  out <- dm_flatten_join(dm_deep, "A", "B", left_join)

  # Transfer B's FK to C so it now points from A to C
  result <- dm_flatten_transfer_fks(out$dm, "A", "B", out$col_renames, all_fks)

  fks <- dm_get_all_fks(result)
  expect_true(any(fks$child_table == "A" & fks$parent_table == "C"))
})

test_that("`dm_flatten_transfer_fks()` handles renamed FK columns", {
  # Create dm where parent's FK column conflicts with child's column
  dm_test <- dm(
    child = tibble::tibble(id = 1:2, pid = 1:2, ref = c("x", "y")),
    parent = tibble::tibble(id = 1:2, ref = 1:2),
    grandparent = tibble::tibble(id = 1:2, info = c("a", "b"))
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_pk(grandparent, id) %>%
    dm_add_fk(child, pid, parent) %>%
    dm_add_fk(parent, ref, grandparent)

  all_fks <- dm_get_all_fks_impl(dm_test, ignore_on_delete = TRUE)
  out <- dm_flatten_join(dm_test, "child", "parent", left_join)

  # ref was renamed to ref.parent
  expect_equal(out$col_renames[["parent"]], c(ref = "ref.parent"))

  result <- dm_flatten_transfer_fks(out$dm, "child", "parent", out$col_renames, all_fks)
  fks <- dm_get_all_fks(result)

  # FK should now be from child.ref.parent to grandparent.id
  fk_row <- fks[fks$child_table == "child" & fks$parent_table == "grandparent", ]
  expect_equal(nrow(fk_row), 1)
  expect_equal(fk_row$child_fk_cols[[1]], "ref.parent")
})

# --- Join argument tests ---

test_that("`dm_flatten()` with `join = inner_join`", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:4, pid = c(1L, 2L, 3L, NA), val = letters[1:4]),
    parent = tibble::tibble(id = 1:3, info = LETTERS[1:3])
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  result <- dm_flatten(dm_test, child, join = inner_join)

  child_tbl <- pull_tbl(result, child)
  # inner_join drops unmatched rows (pid = NA)
  expect_equal(nrow(child_tbl), 3)
  expect_true("info" %in% colnames(child_tbl))
})

test_that("`dm_flatten()` with `join = full_join`", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:2, pid = c(1L, 3L)),
    parent = tibble::tibble(id = 1:3, info = LETTERS[1:3])
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  result <- dm_flatten(dm_test, child, join = full_join)

  child_tbl <- pull_tbl(result, child)
  # full_join keeps all rows from both sides
  expect_true(nrow(child_tbl) >= 2)
  expect_true("info" %in% colnames(child_tbl))
})

test_that("`dm_flatten()` with `join = semi_join`", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:4, pid = c(1L, 2L, 3L, NA), val = letters[1:4]),
    parent = tibble::tibble(id = 1:3, info = LETTERS[1:3])
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  result <- dm_flatten(dm_test, child, join = semi_join)

  child_tbl <- pull_tbl(result, child)
  # semi_join keeps only matching child rows, no parent columns added
  expect_equal(nrow(child_tbl), 3)
  expect_false("info" %in% colnames(child_tbl))
})

test_that("`dm_flatten()` with `join = anti_join`", {
  dm_test <- dm(
    child = tibble::tibble(id = 1:4, pid = c(1L, 2L, 3L, NA), val = letters[1:4]),
    parent = tibble::tibble(id = 1:3, info = LETTERS[1:3])
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_fk(child, pid, parent)

  result <- dm_flatten(dm_test, child, join = anti_join)

  child_tbl <- pull_tbl(result, child)
  # anti_join keeps only non-matching child rows
  expect_equal(nrow(child_tbl), 1)
  expect_false("info" %in% colnames(child_tbl))
})

test_that("`dm_flatten()` errors with `join = nest_join`", {
  expect_dm_error(
    dm_flatten(dm_for_flatten(), fact, join = nest_join),
    class = "no_flatten_with_nest_join"
  )
})

test_that("`dm_flatten()` recursive with non-left join errors", {
  expect_dm_error(
    dm_flatten(dm_more_complex(), tf_5, recursive = TRUE, join = semi_join),
    class = "squash_limited"
  )
})

test_that("`dm_flatten()` recursive with `join = inner_join`", {
  result <- dm_flatten(
    dm_more_complex(),
    tf_5,
    parent_tables = c(tf_4, tf_3),
    recursive = TRUE,
    join = inner_join
  )

  expect_s3_class(result, "dm")
  expect_true("tf_5" %in% names(dm_get_tables(result)))
  expect_false("tf_4" %in% names(dm_get_tables(result)))
  expect_false("tf_3" %in% names(dm_get_tables(result)))
})

test_that("`dm_flatten()` join argument snapshot with `dm_paste()`", {
  expect_snapshot({
    dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2), join = inner_join) %>%
      dm_paste(options = c("select", "keys"))
  })
})
