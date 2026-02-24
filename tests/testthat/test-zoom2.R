test_that("dm_zoom2_to() works", {
  # returns a keyed table
  result <- dm_zoom2_to(dm_for_filter(), tf_1)

  expect_s3_class(result, "dm_keyed_tbl")

  # has zoom2 info in dm_key_info
  keys_info <- keyed_get_info(result)
  expect_false(is.null(keys_info$zoom2))
  expect_equal(keys_info$zoom2$table_name, "tf_1")
})


test_that("dm_zoom2_to() preserves table content", {
  expect_equivalent_tbl(
    dm_zoom2_to(dm_for_filter(), tf_2) %>%
      unclass_keyed_tbl(),
    tf_2()
  )

  expect_equivalent_tbl(
    dm_zoom2_to(dm_for_filter(), tf_3) %>%
      unclass_keyed_tbl(),
    tf_3()
  )
})


test_that("dm_insert_zoom2ed() works", {
  # test that a new tbl is inserted, based on the requested one
  expect_equivalent_dm(
    dm_zoom2_to(dm_for_filter(), tf_4) %>%
      dm_insert_zoom2ed("tf_4_new"),
    dm_for_filter() %>%
      dm(tf_4_new = tf_4()) %>%
      dm_add_pk(tf_4_new, h) %>%
      dm_add_fk(tf_4_new, c(j, j1), tf_3) %>%
      dm_add_fk(tf_5, l, tf_4_new),
    ignore_on_delete = TRUE,
    ignore_autoincrement = TRUE
  )

  # test that an error is thrown if 'repair = check_unique' and duplicate table names
  expect_dm_error(
    dm_zoom2_to(dm_for_filter(), tf_4) %>% dm_insert_zoom2ed("tf_4", repair = "check_unique"),
    "need_unique_names"
  )

  # test that in case of 'repair = unique' and duplicate table names -> renames of old and new
  expect_equivalent_dm(
    dm_for_filter() %>%
      dm_zoom2_to(tf_4) %>%
      dm_insert_zoom2ed("tf_4", repair = "unique", quiet = TRUE),
    dm_for_filter() %>%
      dm_rename_tbl(tf_4...4 = tf_4) %>%
      dm(tf_4...7 = tf_4()) %>%
      dm_add_pk(tf_4...7, h) %>%
      dm_add_fk(tf_4...7, c(j, j1), tf_3) %>%
      dm_add_fk(tf_5, l, tf_4...7),
    ignore_on_delete = TRUE,
    ignore_autoincrement = TRUE
  )
})


test_that("dm_update_zoom2ed() works", {
  # zooming to a table and updating should yield the same dm
  expect_equivalent_dm(
    dm_for_filter() %>%
      dm_zoom2_to(tf_2) %>%
      dm_update_zoom2ed(),
    dm_for_filter(),
    ignore_on_delete = TRUE,
    ignore_autoincrement = TRUE
  )
})


test_that("dm_update_zoom2ed() preserves mutated data", {
  original_dm <- dm_for_filter()
  result_dm <-
    original_dm %>%
    dm_zoom2_to(tf_2) %>%
    mutate(new_col = 1) %>%
    dm_update_zoom2ed()

  # The updated table should have the new column
  expect_true("new_col" %in% colnames(result_dm$tf_2))
})


test_that("dm_discard_zoom2ed() works", {
  original_dm <- dm_for_filter()
  result_dm <-
    original_dm %>%
    dm_zoom2_to(tf_2) %>%
    mutate(new_col = 1) %>%
    dm_discard_zoom2ed()

  # Should return the original dm unchanged
  expect_equivalent_dm(
    result_dm,
    original_dm
  )
  expect_false("new_col" %in% colnames(result_dm$tf_2))
})


test_that("dm_discard_zoom2ed() works after summarise", {
  original_dm <- dm_for_filter()
  result_dm <-
    original_dm %>%
    dm_zoom2_to(tf_2) %>%
    summarise(n = n()) %>%
    dm_discard_zoom2ed()

  expect_equivalent_dm(
    result_dm,
    original_dm
  )
})


# tests for compound keys -------------------------------------------------

test_that("zoom2 output for compound keys", {
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  expect_snapshot({
    nyc_comp() %>% dm_zoom2_to(weather)
    nyc_comp() %>%
      dm_zoom2_to(weather) %>%
      dm_update_zoom2ed()
    nyc_comp_2 <-
      nyc_comp() %>%
      dm_zoom2_to(weather) %>%
      dm_insert_zoom2ed("weather_2")
    nyc_comp_2 %>%
      get_all_keys()

    nyc_comp_3 <-
      nyc_comp() %>%
      dm_zoom2_to(flights) %>%
      dm_insert_zoom2ed("flights_2")
    nyc_comp_3 %>%
      get_all_keys()
  })
})


# test that inserting a zoomed table retains the color --------------------

test_that("dm_insert_zoom2ed() retains color", {
  expect_identical(
    dm_for_filter() %>%
      dm_set_colors("cyan" = tf_2) %>%
      dm_zoom2_to(tf_2) %>%
      dm_insert_zoom2ed("tf_2_new") %>%
      dm_get_def() %>%
      filter(table == "tf_2_new") %>%
      pull(display),
    "#00FFFFFF"
  )
})


# dplyr verb snapshot tests -----------------------------------------------
# Each test constructs a dm inline, applies a dplyr verb via dm_zoom2_to(),
# and uses dm_paste() to show key structure after dm_update_zoom2ed().

# --- Verbs that change key columns ---

test_that("zoom2 select() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      select(id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 select() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      select(child_id, val) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 rename() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      rename(parent_id = id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 rename() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      rename(cid = child_id, pid = parent_id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 summarise() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      summarise(n = n()) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 summarise() on child table with group_by", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      group_by(parent_id) %>%
      summarise(n = n()) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 summarise() insert", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      group_by(parent_id) %>%
      summarise(n = n()) %>%
      dm_insert_zoom2ed("child_summary") %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 summarise() on child table with .by", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      summarise(n = n(), .by = parent_id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 summarise() insert with .by", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      summarise(n = n(), .by = parent_id) %>%
      dm_insert_zoom2ed("child_summary") %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 reframe() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      reframe(n = n()) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 reframe() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      reframe(n = n(), .by = parent_id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 tally() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      tally() %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 tally() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      tally() %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 left_join()", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      left_join(dm_zoom2_to(d, parent)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 inner_join()", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      inner_join(dm_zoom2_to(d, parent)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 semi_join()", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      semi_join(dm_zoom2_to(d, parent)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 anti_join()", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      anti_join(dm_zoom2_to(d, parent)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 right_join()", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      right_join(dm_zoom2_to(d, parent)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 full_join()", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      full_join(dm_zoom2_to(d, parent)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 cross_join()", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      cross_join(dm_zoom2_to(d, parent)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 left_join() insert", {
  skip_if_remote_src()
  expect_snapshot({
    d <- dm(
      grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")),
      parent = tibble(id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(grandparent, gp_id) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(parent, gp_id, grandparent) %>%
      dm_add_fk(child, parent_id, parent)

    d %>%
      dm_zoom2_to(child) %>%
      left_join(dm_zoom2_to(d, parent)) %>%
      dm_insert_zoom2ed("child_parent") %>%
      dm_paste(options = "all")
  })
})

# --- Verbs that don't change key columns (parent + child) ---

test_that("zoom2 filter() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      filter(id > 1) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 filter() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      filter(val != "a") %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 mutate() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      mutate(name2 = toupper(name)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 mutate() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      mutate(val2 = toupper(val)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 arrange() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      arrange(desc(id)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 arrange() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      arrange(desc(child_id)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 distinct() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      distinct() %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 distinct() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      distinct() %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 slice() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      slice(1:2) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 slice() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      slice(1:3) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 transmute() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      transmute(id, name_upper = toupper(name)) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 transmute() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      transmute(child_id, parent_id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 relocate() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      relocate(name, .before = id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 relocate() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      relocate(val, .before = child_id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 group_by() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      group_by(name) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 group_by() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      group_by(parent_id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 ungroup() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      group_by(name) %>%
      ungroup() %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 ungroup() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      group_by(parent_id) %>%
      ungroup() %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 count() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      count(name) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 count() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      count(parent_id) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

# --- tidyr verbs ---

test_that("zoom2 unite() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, first = c("a", "b", "c"), last = c("x", "y", "z")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      tidyr::unite(full_name, first, last) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 unite() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(
        child_id = 1:4,
        parent_id = c(1L, 1L, 2L, 3L),
        first = c("a", "b", "c", "d"),
        last = c("w", "x", "y", "z")
      )
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      tidyr::unite(full_name, first, last) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 separate() on parent table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, full_name = c("a_x", "b_y", "c_z")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(parent) %>%
      tidyr::separate(full_name, into = c("first", "last")) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})

test_that("zoom2 separate() on child table", {
  skip_if_remote_src()
  expect_snapshot({
    dm(
      parent = tibble(id = 1:3, name = c("a", "b", "c")),
      child = tibble(
        child_id = 1:4,
        parent_id = c(1L, 1L, 2L, 3L),
        full_val = c("a_1", "b_2", "c_3", "d_4")
      )
    ) %>%
      dm_add_pk(parent, id) %>%
      dm_add_pk(child, child_id) %>%
      dm_add_fk(child, parent_id, parent) %>%
      dm_zoom2_to(child) %>%
      tidyr::separate(full_val, into = c("letter", "number")) %>%
      dm_update_zoom2ed() %>%
      dm_paste(options = "all")
  })
})
