test_that("can access tables", {
  expect_identical(tbl(dm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_dm_error(
    tbl(dm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("can create dm with as_dm()", {
  expect_equivalent_dm(as_dm(dm_get_tables(dm_test_obj)), dm_test_obj)
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
    copy_to(dm_for_filter, letters[1:5], name = "letters"),
    "only_data_frames_supported"
  )

  expect_dm_error(
    copy_to(dm_for_filter, list(mtcars, iris)),
    "only_data_frames_supported"
  )

  expect_dm_error(
    copy_to(dm_for_filter, mtcars, overwrite = TRUE),
    "no_overwrite"
  )

  expect_equivalent_dm(
    copy_to(dm_for_filter, mtcars, "car_table"),
    dm_add_tbl(dm_for_filter, car_table = mtcars)
  )

  expect_dm_error(
    copy_to(dm_for_filter, mtcars, c("car_table", "another_table")),
    "one_name_for_copy_to"
  )

  expect_name_repair_message(
    expect_equivalent_dm(
      copy_to(dm_for_filter, mtcars, ""),
      dm_add_tbl(dm_for_filter, ...7 = mtcars)
    )
  )

  # rename old and new tables if `repair = unique`
  expect_name_repair_message(
    expect_equivalent_dm(
      dm(mtcars) %>% copy_to(mtcars),
      dm(mtcars...1 = mtcars, mtcars...2 = mtcars)
    )
  )

  expect_equivalent_dm(
    expect_silent(
      dm(mtcars) %>% copy_to(mtcars, quiet = TRUE)
    ),
    dm(mtcars...1 = mtcars, mtcars...2 = mtcars)
  )

  # throw error if duplicate table names and `repair = check_unique`
  expect_dm_error(
    dm(mtcars) %>% copy_to(mtcars, repair = "check_unique"),
    "need_unique_names"
  )

  # copying `tibble` from chosen src to sqlite `dm`
  expect_equivalent_dm(
    copy_to(dm_for_filter_sqlite, d1, "test_table"),
    dm_add_tbl(dm_for_filter_sqlite, test_table = d1_sqlite)
  )

  # copying sqlite `tibble` to `dm` on src of choice
  expect_equivalent_dm(
    copy_to(dm_for_filter, d1_sqlite, "test_table_1"),
    dm_add_tbl(dm_for_filter, test_table_1 = d1)
  )
})

test_that("'compute.dm()' computes tables on DB", {
  skip_if_local_src(my_test_src)
  def <-
    dm_for_filter %>%
    dm_filter(t1, a > 3) %>%
    compute() %>%
    dm_get_def()
  test <- map_chr(map(def$data, sql_render), as.character)
  # no filtering is part of the SQL-query anymore, since the filtered table is "computed"
  expect_true(all(map_lgl(test, ~ !grepl("WHERE", .))))
})

test_that("'compute.zoomed_dm()' computes tables on DB", {
  skip_if_local_src(my_test_src)
  zoomed_dm_for_compute <- dm_for_filter %>%
    dm_zoom_to(t1) %>%
    mutate(c = a + 1)
  # "1" is without computing
  def_1 <- dm_update_zoomed(zoomed_dm_for_compute) %>% dm_get_def()
  # "2" is with computing
  def_2 <- compute(zoomed_dm_for_compute) %>%
    dm_update_zoomed() %>%
    dm_get_def()
  test_1 <- map_chr(map(def_1$data, sql_render), as.character)
  test_2 <- map_chr(map(def_2$data, sql_render), as.character)

  expect_true(!all(map_lgl(test_1, ~ !grepl("1.0 AS `c`", .))))
  expect_true(all(map_lgl(test_2, ~ !grepl("1.0 AS `c`", .))))
})

test_that("some methods/functions for `zoomed_dm` work", {
  expect_identical(
    colnames(dm_zoom_to(dm_for_filter, t1)),
    c("a", "b")
  )

  expect_identical(
    dim(dm_zoom_to(dm_for_filter, t1)),
    c(10L, 2L)
  )
})

test_that("validator is silent", {
  expect_identical(
    expect_silent(validate_dm(new_dm())),
    empty_dm()
  )

  expect_identical(
    expect_silent(validate_dm(dm_for_filter_w_cycle)),
    dm_for_filter_w_cycle
  )
})

test_that("validator speaks up (sqlite)", {
  # FIXME: PR #313: will this test fail, if chosen `src` is SQLite?
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>%
      mutate(data = if_else(table == "t1", list(dm_for_filter_sqlite$t1), data))) %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("validator speaks up when something's wrong", {
  # col tracker of non-zoomed dm contains entries
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>% mutate(col_tracker_zoom = list(1))) %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of `zoomed_dm` is empty
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter %>% dm_zoom_to(t1)) %>% mutate(zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
    "dm_invalid"
  )

  # col tracker of zoomed dm is empty
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter %>% dm_zoom_to(t1)) %>% mutate(col_tracker_zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
    "dm_invalid"
  )

  # table name is missing
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>% mutate(table = "")) %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of un-zoomed dm contains a (nonsensical) entry
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>% mutate(zoom = list(1))) %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains a nonsensical entry
  expect_dm_error(
    new_dm3(dm_for_filter %>%
      dm_zoom_to(t1) %>%
      dm_get_def() %>%
      mutate(zoom = if_else(table == "t1", list(1), NULL)), zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains more than one entry
  expect_dm_error(
    new_dm3(dm_for_filter %>%
      dm_zoom_to(t1) %>%
      dm_get_def() %>%
      mutate(zoom = list(t1)), zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # data column of un-zoomed dm contains non-tibble entries
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>% mutate(data = list(1, 2, 3, 4, 5, 6))) %>% validate_dm(),
    "dm_invalid"
  )

  # PK metadata wrong (colname doesn't exist)
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>% mutate(pks = if_else(table == "t1", vctrs::list_of(new_pk(list("z"))), pks))) %>%
      validate_dm(),
    "dm_invalid"
  )

  # FK metadata wrong (table doesn't exist)
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>%
      mutate(fks = if_else(table == "t3", vctrs::list_of(new_fk(table = "t8", list("z"))), fks))) %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("`pull_tbl()`-methods work", {
  expect_equivalent_tbl(
    pull_tbl(dm_for_filter, t5),
    t5
  )

  expect_equivalent_tbl(
    dm_zoom_to(dm_for_filter, t3) %>%
      mutate(new_col = row_number() * 3) %>%
      pull_tbl() %>%
      collect(),
    mutate(t3, new_col = row_number() * 3)
  )

  expect_equivalent_tbl(
    dm_zoom_to(dm_for_filter, t1) %>% pull_tbl(t1),
    t1
  )

  expect_dm_error(
    dm_zoom_to(dm_for_filter, t1) %>% pull_tbl(t2),
    "table_not_zoomed"
  )

  expect_dm_error(
    pull_tbl(dm_for_filter),
    "no_table_provided"
  )

  expect_dm_error(
    dm_get_def(dm_for_filter) %>%
      mutate(zoom = list(t1)) %>%
      new_dm3(zoomed = TRUE) %>%
      pull_tbl(),
    "not_pulling_multiple_zoomed"
  )
})

test_that("numeric subsetting works", {

  # check specifically for the right output in one case
  expect_equivalent_tbl(dm_for_filter[[4]], t4)

  # compare numeric subsetting and subsetting by name on chosen src
  expect_equivalent_tbl(
    dm_for_filter[["t2"]],
    dm_for_filter[[2]]
  )

  # check if reducing `dm` size (and reordering) works on chosen src
  expect_equivalent_dm(
    dm_for_filter[c(1, 5, 3)],
    dm_select_tbl(dm_for_filter, 1, 5, 3)
  )
})

test_that("subsetting `dm` works", {
  expect_equivalent_tbl(dm_for_filter$t5, t5)
  expect_equivalent_tbl(dm_for_filter[["t3"]], t3)
})

test_that("subsetting `zoomed_dm` works", {
  skip_if_remote_src(my_test_src)
  expect_identical(
    dm_zoom_to(dm_for_filter, t2)$c,
    pull(t2, c)
  )

  expect_identical(
    dm_zoom_to(dm_for_filter, t3)[["g"]],
    pull(t3, g)
  )

  expect_identical(
    dm_zoom_to(dm_for_filter, t3)[c("g", "f", "g")],
    t3[c("g", "f", "g")]
  )
})

test_that("methods for dm/zoomed_dm work", {
  expect_length(dm_for_filter, 6L)

  expect_identical(names(dm_for_filter), src_tbls(dm_for_filter))
  expect_identical(names(dm_zoom_to(dm_for_filter, t2)), colnames(t2))
})

test_that("method length.zoomed_dm() works locally", {
  skip_if_remote_src(my_test_src)
  expect_length(dm_zoom_to(dm_for_filter, t2), 3L)
})

test_that("as.list()-method works for `dm`", {
  expect_equivalent_tbl_lists(
    as.list(dm_for_filter),
    list_for_filter
  )
})

test_that("as.list()-method works for `zoomed_dm`", {
  # as.list() is no-op for `tbl_sql` object
  skip_if_remote_src(my_test_src)
  expect_identical(
    as.list(dm_for_filter %>% dm_zoom_to(t4)),
    as.list(t4)
  )
})


# test getters: -----------------------------------------------------------

test_that("dm_get_src() works", {
  expect_dm_error(
    dm_get_src(1),
    class = "is_not_dm"
  )

  expect_identical(
    class(dm_get_src(dm_for_filter)),
    class(my_test_src)
  )
})

test_that("dm_get_con() errors", {
  expect_dm_error(
    dm_get_con(1),
    class = "is_not_dm"
  )

  expect_dm_error(
    dm_get_con(dm_for_filter),
    class = "con_only_for_dbi"
  )
})

test_that("dm_get_con() works", {
  skip_if_local_src(my_test_src)
  expect_identical(
    dm_get_con(dm_for_filter),
    my_test_src$con
  )
})

test_that("dm_get_filters() works", {
  expect_identical(
    dm_get_filters(dm_for_filter),
    tibble(table = character(), filter = list(), zoomed = logical())
  )

  expect_identical(
    dm_get_filters(dm_filter(dm_for_filter, t1, a > 3, a < 8)),
    tibble(table = "t1", filter = unname(exprs(a > 3, a < 8)), zoomed = FALSE)
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
