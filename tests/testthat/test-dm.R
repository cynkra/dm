test_that("can create dm with as_dm()", {
  expect_equivalent_dm(as_dm(dm_get_tables(dm_test_obj())), dm_test_obj())
})

test_that("creation of empty `dm` works", {
  expect_true(
    is_empty(dm())
  )

  expect_true(
    is_empty(new_dm())
  )
})

test_that("'collect.dm()' collects tables on DB", {
  def <-
    dm_for_filter() %>%
    dm_filter(tf_1, a > 3) %>%
    collect() %>%
    dm_get_def()

  is_df <- map_lgl(def$data, is.data.frame)
  expect_true(all(is_df))
})

test_that("'collect.zoomed_dm()' collects tables, with message", {
  zoomed_dm_for_collect <-
    dm_for_filter() %>%
    dm_zoom_to(tf_1) %>%
    mutate(c = a + 1)

  expect_message(
    out <- zoomed_dm_for_collect %>% collect(),
    "pull_tbl"
  )

  expect_s3_class(out, "data.frame")
})

test_that("'compute.dm()' computes tables on DB", {
  skip_if_local_src()
  skip("Needs https://github.com/tidyverse/dbplyr/pull/649")

  def <-
    dm_for_filter() %>%
    dm_filter(tf_1, a > 3) %>%
    {
      suppress_mssql_message(compute(.))
    } %>%
    dm_get_def()

  remote_names <- map(def$data, dbplyr::remote_name)
  expect_equal(lengths(remote_names), rep_along(remote_names, 1))
})

test_that("'compute.zoomed_dm()' computes tables on DB", {
  skip_if_local_src()
  skip("Needs https://github.com/tidyverse/dbplyr/pull/649")

  zoomed_dm_for_compute <-
    dm_for_filter() %>%
    dm_zoom_to(tf_1) %>%
    mutate(c = a + 1)

  # without computing
  def <-
    zoomed_dm_for_compute %>%
    dm_update_zoomed() %>%
    dm_get_def()

  remote_names <- map(def$data, dbplyr::remote_name)
  expect_true(any(map_lgl(remote_names, is_null)))

  # with computing
  def <-
    suppress_mssql_message(compute(zoomed_dm_for_compute)) %>%
    dm_update_zoomed() %>%
    dm_get_def()

  remote_names <- map(def$data, dbplyr::remote_name)
  expect_equal(lengths(remote_names), rep_along(remote_names, 1))
})

test_that("some methods/functions for `zoomed_dm` work", {
  expect_identical(
    colnames(dm_zoom_to(dm_for_filter(), tf_1)),
    c("a", "b")
  )

  expect_identical(
    ncol(dm_zoom_to(dm_for_filter(), tf_1)),
    2L
  )

  expect_equivalent_tbl_lists(
    as.list(dm_for_filter()),
    dm_get_tables(dm_for_filter())
  )

  skip_if_remote_src()
  expect_identical(
    dim(dm_zoom_to(dm_for_filter(), tf_1)),
    c(10L, 2L)
  )
  expect_identical(
    names(dm_zoom_to(dm_for_filter(), tf_2)),
    colnames(tf_2())
  )
})

test_that("length and names for dm work", {
  expect_length(dm_for_filter(), 6L)
  expect_identical(names(dm_for_filter()), src_tbls_impl(dm_for_filter()))
})

test_that("validator is silent", {
  expect_identical(
    expect_silent(validate_dm(new_dm())),
    empty_dm()
  )

  expect_identical(
    expect_silent(validate_dm(dm_for_filter_w_cycle())),
    dm_for_filter_w_cycle()
  )
})

test_that("validator speaks up (sqlite())", {
  skip_if_not_installed("dbplyr")

  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(data = if_else(table == "tf_1", list(dm_for_filter_sqlite()$tf_1), data)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("validator speaks up when something's wrong", {
  # col tracker of non-zoomed dm contains entries
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(col_tracker_zoom = list(1)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of `zoomed_dm` is empty
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = list(NULL)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # col tracker of zoomed dm is empty
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(col_tracker_zoom = list(NULL)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # table name is missing
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(table = "") %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of un-zoomed dm contains a (nonsensical) entry
  expect_dm_error(
    dm_get_def(dm_for_filter()) %>% mutate(zoom = list(1)) %>% new_dm3() %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains a nonsensical entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = if_else(table == "tf_1", list(1), NULL)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains more than one entry
  expect_dm_error(
    dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = list(tf_1)) %>%
      new_dm3(zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # data column of un-zoomed dm contains non-tibble entries
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(data = list(1, 2, 3, 4, 5, 6)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # PK metadata wrong (colname doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(pks = if_else(table == "tf_1", vctrs::list_of(new_pk(list("z"))), pks)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )

  # FK metadata wrong (table doesn't exist)
  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(fks = if_else(table == "tf_3", vctrs::list_of(new_fk(table = "tf_8", list("z"))), fks)) %>%
      new_dm3() %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("`pull_tbl()`-methods work", {
  expect_equivalent_tbl(
    pull_tbl(dm_for_filter(), tf_5),
    tf_5()
  )

  skip_if_src("maria")
  expect_equivalent_tbl(
    dm_for_filter() %>%
      dm_zoom_to(tf_3) %>%
      mutate(new_col = row_number(f) * 3) %>%
      pull_tbl(),
    mutate(tf_3(), new_col = row_number(f) * 3)
  )
})

test_that("`pull_tbl()`-methods work (2)", {
  expect_equivalent_tbl(
    dm_zoom_to(dm_for_filter(), tf_1) %>% pull_tbl(tf_1),
    tf_1()
  )

  expect_dm_error(
    dm_zoom_to(dm_for_filter(), tf_1) %>% pull_tbl(tf_2),
    "table_not_zoomed"
  )

  expect_dm_error(
    pull_tbl(dm_for_filter()),
    "no_table_provided"
  )

  expect_dm_error(
    dm_for_filter() %>%
      dm_get_def() %>%
      mutate(zoom = list(tf_1)) %>%
      new_dm3(zoomed = TRUE) %>%
      pull_tbl(),
    "not_pulling_multiple_zoomed"
  )
})

test_that("numeric subsetting works", {

  # check specifically for the right output in one case
  expect_equivalent_tbl(dm_for_filter()[[4]], tf_4())

  # compare numeric subsetting and subsetting by name on chosen src
  expect_equivalent_tbl(
    dm_for_filter()[["tf_2"]],
    dm_for_filter()[[2]]
  )

  # check if reducing `dm` size (and reordering) works on chosen src
  expect_equivalent_dm(
    dm_for_filter()[c(1, 5, 3)],
    dm_select_tbl(dm_for_filter(), 1, 5, 3)
  )
})

test_that("subsetting `dm` works", {
  expect_equivalent_tbl(dm_for_filter()$tf_5, tf_5())
  expect_equivalent_tbl(dm_for_filter()[["tf_3"]], tf_3())
})

test_that("subsetting `zoomed_dm` works", {
  skip_if_remote_src()
  expect_identical(
    dm_zoom_to(dm_for_filter(), tf_2)$c,
    pull(tf_2(), c)
  )

  expect_identical(
    dm_zoom_to(dm_for_filter(), tf_3)[["g"]],
    pull(tf_3(), g)
  )

  expect_identical(
    dm_zoom_to(dm_for_filter(), tf_3)[c("g", "f", "g")],
    tf_3()[c("g", "f", "g")]
  )
})

test_that("as.list()-method works for local `zoomed_dm`", {
  skip_if_remote_src()
  expect_identical(
    as.list(dm_for_filter() %>% dm_zoom_to(tf_4)),
    as.list(tf_4())
  )
})

# test getters: -----------------------------------------------------------

test_that("dm_get_src() works", {
  local_options(lifecycle_verbosity = "quiet")

  expect_dm_error(
    dm_get_src(1),
    class = "is_not_dm"
  )

  expect_identical(
    class(dm_get_src(dm_for_filter())),
    class(my_test_src())
  )
})

test_that("dm_get_con() errors", {
  expect_dm_error(
    dm_get_con(1),
    class = "is_not_dm"
  )

  skip_if_remote_src()
  expect_dm_error(
    dm_get_con(dm_for_filter()),
    class = "con_only_for_dbi"
  )
})

test_that("dm_get_con() works", {
  skip_if_local_src()
  expect_identical(
    dm_get_con(dm_for_filter()),
    con_from_src_or_con(my_test_src())
  )
})

test_that("dm_get_filters() works", {
  expect_identical(
    dm_get_filters(dm_for_filter()),
    tibble(table = character(), filter = list(), zoomed = logical())
  )

  expect_identical(
    dm_get_filters(dm_filter(dm_for_filter(), tf_1, a > 3, a < 8)),
    tibble(table = "tf_1", filter = unname(exprs(a > 3, a < 8)), zoomed = FALSE)
  )
})


test_that("output", {
  skip_if_not_installed("nycflights13")

  expect_snapshot({
    print(dm())

    nyc_flights_dm <- dm_nycflights_small()
    collect(nyc_flights_dm)

    nyc_flights_dm %>%
      format()

    nyc_flights_dm %>%
      dm_filter(flights, origin == "EWR") %>%
      collect()

    dm_for_filter() %>%
      str()

    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      str()
  })
})


# Compound tests ----------------------------------------------------------


test_that("output for compound keys", {
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  # Can't be inside the snapshot
  car_table <- test_src_frame(!!!mtcars)

  expect_snapshot({
    copy_to(nyc_comp(), mtcars, "car_table")
    dm_add_tbl(nyc_comp(), car_table)
    nyc_comp() %>%
      collect()
    nyc_comp() %>%
      dm_filter(flights, day == 10) %>%
      compute() %>%
      collect() %>%
      dm_get_def()
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      mutate(origin_new = paste0(origin, " airport")) %>%
      compute() %>%
      dm_update_zoomed() %>%
      collect() %>%
      dm_get_def()
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      collect()
    pull_tbl(nyc_comp(), weather)
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      pull_tbl()
  })
})
