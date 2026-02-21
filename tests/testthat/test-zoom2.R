test_that("dm_zoom2_to() works", {
  # returns a keyed table
  result <- dm_zoom2_to(dm_for_filter(), tf_1)

  expect_s3_class(result, "dm_keyed_tbl")

  # has dm_zoom2 attributes
  expect_false(is.null(attr(result, "dm_zoom2_src_dm")))
  expect_false(is.null(attr(result, "dm_zoom2_src_name")))
  expect_equal(attr(result, "dm_zoom2_src_name"), "tf_1")
})


test_that("dm_zoom2_to() preserves table content", {
  expect_equivalent_tbl(
    dm_zoom2_to(dm_for_filter(), tf_2) %>%
      zoom2_clean_attrs() %>%
      unclass_keyed_tbl(),
    tf_2()
  )

  expect_equivalent_tbl(
    dm_zoom2_to(dm_for_filter(), tf_3) %>%
      zoom2_clean_attrs() %>%
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
# Each test creates a simple dm, applies a dplyr verb via dm_zoom2_to(),
# then uses dm_paste() to show key structure after dm_update_zoom2ed().

local({
  # Simple dm used across all verb tests
  d <- dm(
    parent = tibble(id = 1:3, name = c("a", "b", "c")),
    child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])
  ) %>%
    dm_add_pk(parent, id) %>%
    dm_add_pk(child, child_id) %>%
    dm_add_fk(child, parent_id, parent)

  # Helper: zoom, apply verb, update and paste. Works for all verbs
  # including those that strip zoom2 attributes (summarise, reframe, etc.)

  zoom2_verb_paste <- function(dm, table_name, verb_fn) {
    zoomed <- dm_zoom2_to(dm, !!table_name)
    modified <- verb_fn(zoomed)
    # Build keyed tables from original dm and replace the zoomed one
    keyed_tables <- dm_get_keyed_tables_impl(dm)
    keyed_tables[[table_name]] <- zoom2_clean_attrs(modified)
    new_dm(keyed_tables) %>% dm_paste(options = "all")
  }

  # --- Verbs that change key columns ---

  test_that("zoom2 select() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) select(z, id))
    })
  })

  test_that("zoom2 select() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) select(z, child_id, val))
    })
  })

  test_that("zoom2 rename() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) rename(z, parent_id = id))
    })
  })

  test_that("zoom2 rename() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) rename(z, cid = child_id, pid = parent_id))
    })
  })

  test_that("zoom2 summarise() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) summarise(z, n = n()))
    })
  })

  test_that("zoom2 summarise() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) {
        z %>% group_by(parent_id) %>% summarise(n = n())
      })
    })
  })

  test_that("zoom2 left_join()", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) {
        left_join(z, dm_zoom2_to(d, parent))
      })
    })
  })

  test_that("zoom2 inner_join()", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) {
        inner_join(z, dm_zoom2_to(d, parent))
      })
    })
  })

  test_that("zoom2 semi_join()", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) {
        semi_join(z, dm_zoom2_to(d, parent))
      })
    })
  })

  test_that("zoom2 anti_join()", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) {
        anti_join(z, dm_zoom2_to(d, parent))
      })
    })
  })

  # --- Verbs that don't change key columns (parent + child) ---

  test_that("zoom2 filter() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) filter(z, id > 1))
    })
  })

  test_that("zoom2 filter() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) filter(z, val != "a"))
    })
  })

  test_that("zoom2 mutate() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) mutate(z, name2 = toupper(name)))
    })
  })

  test_that("zoom2 mutate() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) mutate(z, val2 = toupper(val)))
    })
  })

  test_that("zoom2 arrange() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) arrange(z, desc(id)))
    })
  })

  test_that("zoom2 arrange() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) arrange(z, desc(child_id)))
    })
  })

  test_that("zoom2 distinct() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) distinct(z))
    })
  })

  test_that("zoom2 distinct() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) distinct(z))
    })
  })

  test_that("zoom2 slice() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) slice(z, 1:2))
    })
  })

  test_that("zoom2 slice() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) slice(z, 1:3))
    })
  })

  test_that("zoom2 transmute() on parent table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "parent", function(z) transmute(z, id, name_upper = toupper(name)))
    })
  })

  test_that("zoom2 transmute() on child table", {
    skip_if_remote_src()
    expect_snapshot({
      zoom2_verb_paste(d, "child", function(z) transmute(z, child_id, parent_id))
    })
  })
})
