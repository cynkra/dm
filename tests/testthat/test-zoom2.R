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
