test_that("can access tables", {
  expect_identical(tbl(dm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_dm_error(
    tbl(dm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

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

test_that("'copy_to.dm()' works", {
  expect_dm_error(
    copy_to(dm_for_filter(), letters[1:5], name = "letters"),
    "only_data_frames_supported"
  )

  expect_dm_error(
    copy_to(dm_for_filter(), list(mtcars, iris)),
    "only_data_frames_supported"
  )

  expect_dm_error(
    copy_to(dm_for_filter(), mtcars, overwrite = TRUE),
    "no_overwrite"
  )

  skip_if_remote_src()
  expect_equivalent_dm(
    copy_to(dm_for_filter(), mtcars, "car_table"),
    dm_add_tbl(dm_for_filter(), car_table = tibble(mtcars))
  )

  expect_name_repair_message(
    expect_equivalent_dm(
      copy_to(dm_for_filter(), mtcars, ""),
      # `tibble()` call necessary cause of #322
      dm_add_tbl(dm_for_filter(), ...7 = tibble(mtcars))
    )
  )
})

test_that("'copy_to.dm()' works (2)", {
  expect_dm_error(
    copy_to(dm_for_filter(), mtcars, c("car_table", "another_table")),
    "one_name_for_copy_to"
  )

  # rename old and new tables if `repair = unique`
  expect_name_repair_message(
    expect_equivalent_dm(
      dm(mtcars) %>% copy_to(mtcars),
      dm(mtcars...1 = mtcars, mtcars...2 = tibble(mtcars))
    )
  )

  expect_equivalent_dm(
    expect_silent(
      dm(mtcars) %>% copy_to(mtcars, quiet = TRUE)
    ),
    dm(mtcars...1 = mtcars, mtcars...2 = tibble(mtcars))
  )

  # throw error if duplicate table names and `repair = check_unique`
  expect_dm_error(
    dm(mtcars) %>% copy_to(mtcars, repair = "check_unique"),
    "need_unique_names"
  )

  # copying `tibble` from chosen src to sqlite() `dm`
  expect_equivalent_dm(
    copy_to(dm_for_filter_sqlite(), data_card_1(), "test_table"),
    dm_add_tbl(dm_for_filter_sqlite(), test_table = data_card_1_sqlite())
  )

  # copying sqlite() `tibble` to `dm` on src of choice
  expect_equivalent_dm(
    copy_to(dm_for_filter(), data_card_1_sqlite(), "test_table_1"),
    dm_add_tbl(dm_for_filter(), test_table_1 = data_card_1())
  )
})

test_that("'compute.dm()' computes tables on DB", {
  skip_if_local_src()
  def <-
    dm_for_filter() %>%
    dm_filter(tf_1, a > 3) %>%
    compute() %>%
    dm_get_def()
  test <- map_chr(map(def$data, sql_render), as.character)
  # no filtering is part of the SQL-query anymore, since the filtered table is "computed"
  expect_true(all(map_lgl(test, ~ !grepl("WHERE", .))))
})

test_that("'compute.zoomed_dm()' computes tables on DB", {
  skip_if_local_src()
  zoomed_dm_for_compute <- dm_for_filter() %>%
    dm_zoom_to(tf_1) %>%
    mutate(c = a + 1)
  # "1" is without computing
  def_1 <- dm_update_zoomed(zoomed_dm_for_compute) %>% dm_get_def()
  # "2" is with computing
  def_2 <- compute(zoomed_dm_for_compute) %>%
    dm_update_zoomed() %>%
    dm_get_def()
  test_1 <- map_chr(map(def_1$data, sql_render), as.character)
  test_2 <- map_chr(map(def_2$data, sql_render), as.character)

  skip_if_remote_src()
  expect_true(!all(map_lgl(test_1, ~ !grepl("1.0 AS `c`", .))))
  expect_true(all(map_lgl(test_2, ~ !grepl("1.0 AS `c`", .))))
})

test_that("some methods/functions for `zoomed_dm` work", {
  expect_identical(
    colnames(dm_zoom_to(dm_for_filter(), tf_1)),
    c("a", "b")
  )

  skip_if_remote_src()
  # FIXME: test for 'ncol()'?
  expect_identical(
    dim(dm_zoom_to(dm_for_filter(), tf_1)),
    c(10L, 2L)
  )
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
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter()) %>%
      mutate(data = if_else(table == "tf_1", list(dm_for_filter_sqlite()$tf_1), data))) %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("validator speaks up when something's wrong", {
  # col tracker of non-zoomed dm contains entries
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter()) %>% mutate(col_tracker_zoom = list(1))) %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of `zoomed_dm` is empty
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter() %>% dm_zoom_to(tf_1)) %>% mutate(zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
    "dm_invalid"
  )

  # col tracker of zoomed dm is empty
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter() %>% dm_zoom_to(tf_1)) %>% mutate(col_tracker_zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
    "dm_invalid"
  )

  # table name is missing
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter()) %>% mutate(table = "")) %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of un-zoomed dm contains a (nonsensical) entry
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter()) %>% mutate(zoom = list(1))) %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains a nonsensical entry
  expect_dm_error(
    new_dm3(dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = if_else(table == "tf_1", list(1), NULL)), zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains more than one entry
  expect_dm_error(
    new_dm3(dm_for_filter() %>%
      dm_zoom_to(tf_1) %>%
      dm_get_def() %>%
      mutate(zoom = list(tf_1)), zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # data column of un-zoomed dm contains non-tibble entries
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter()) %>% mutate(data = list(1, 2, 3, 4, 5, 6))) %>% validate_dm(),
    "dm_invalid"
  )

  # PK metadata wrong (colname doesn't exist)
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter()) %>% mutate(pks = if_else(table == "tf_1", vctrs::list_of(new_pk(list("z"))), pks))) %>%
      validate_dm(),
    "dm_invalid"
  )

  # FK metadata wrong (table doesn't exist)
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter()) %>%
      mutate(fks = if_else(table == "tf_3", vctrs::list_of(new_fk(table = "tf_8", list("z"))), fks))) %>%
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
    dm_zoom_to(dm_for_filter(), tf_3) %>%
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
    dm_get_def(dm_for_filter()) %>%
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

test_that("methods for dm/zoomed_dm work", {
  expect_length(dm_for_filter(), 6L)

  expect_identical(names(dm_for_filter()), src_tbls(dm_for_filter()))
  skip_if_remote_src()
  expect_identical(names(dm_zoom_to(dm_for_filter(), tf_2)), colnames(tf_2()))
})

test_that("method length.zoomed_dm() works locally", {
  skip_if_remote_src()
  expect_length(dm_zoom_to(dm_for_filter(), tf_2), 3L)
})

test_that("as.list()-method works for `dm`", {
  expect_equivalent_tbl_lists(
    as.list(dm_for_filter()),
    dm_get_tables(dm_for_filter())
  )
})

test_that("as.list()-method works for `zoomed_dm`", {
  # as.list() is no-op for `tbl_sql` object
  skip_if_remote_src()
  expect_identical(
    as.list(dm_for_filter() %>% dm_zoom_to(tf_4)),
    as.list(tf_4())
  )
})


# test getters: -----------------------------------------------------------

test_that("dm_get_src() works", {
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
  nyc_flights_dm <- dm_nycflights13(cycle = TRUE)
  verify_output("out/output.txt", {
    nyc_flights_dm

    nyc_flights_dm %>%
      format()

    nyc_flights_dm %>%
      dm_filter(flights, origin == "EWR")
  })
})
