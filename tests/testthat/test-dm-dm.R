test_that("can access tables", {
  expect_identical(tbl(dm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_dm_error(
    tbl(dm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("can create dm with as_dm()", {
  test_obj_df <- as_dm(dm_get_tables(dm_test_obj))

  walk(
    dm_test_obj_src, ~ expect_equivalent_dm(as_dm(dm_get_tables(.)), test_obj_df)
  )
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

  expect_equivalent_dm(
    expect_message(
      copy_to(dm_for_filter, mtcars, ""),
      "New names"
    ),
    dm_add_tbl(dm_for_filter, ...7 = mtcars)
  )

  # rename old and new tables if `repair = unique`
  expect_equivalent_dm(
    expect_message(
      dm(mtcars) %>% copy_to(mtcars),
      "New names:"
    ),
    dm(mtcars...1 = mtcars, mtcars...2 = mtcars)
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

  # copying local `tibble` to postgres `dm`
  skip_if_error(
    expect_equivalent_dm(
      copy_to(dm_for_filter_src$postgres, d1_src$df, "test_table"),
      dm_add_tbl(dm_for_filter_src$postgres, test_table = d1_src$postgres)
    )
  )

  # copying postgres `tibble` to local `dm`
  skip_if_error(
    expect_equivalent_dm(
      copy_to(dm_for_filter_src$df, d1_src$postgres, "test_table_1"),
      dm_add_tbl(dm_for_filter_src$df, test_table_1 = d1_src$df)
    )
  )
})

test_that("'compute.dm()' computes tables on DB", {
  db_src_names <- setdiff(src_names, c("df"))
  skip_if(is_empty(db_src_names))
  walk(
    db_src_names,
    ~ expect_true({
      def <- dm_for_filter_src[[.x]] %>%
        dm_filter(t1, a > 3) %>%
        compute() %>%
        dm_get_def()
      test <- map_chr(map(def$data, sql_render), as.character)
      all(map_lgl(test, ~ !grepl("WHERE", .)))
    })
  )
})

test_that("some methods/functions for `zoomed_dm` work", {
  expect_identical(
    colnames(dm_zoom_to_tbl(dm_for_filter, t1)),
    c("a", "b")
  )

  expect_identical(
    dim(dm_zoom_to_tbl(dm_for_filter, t1)),
    c(10L, 2L)
  )
})

test_that("validator is silent", {
  expect_identical(
    validate_dm(new_dm()),
    empty_dm()
  )

  expect_identical(
    validate_dm(dm_for_filter_w_cycle),
    dm_for_filter_w_cycle
  )
})

test_that("validator speaks up (postgres)", {
  skip_if_not("postgres" %in% src_names)
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>%
      mutate(data = if_else(table == "t1", list(dm_for_filter_src$postgres$t1), data))) %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("validator speaks up (sqlite)", {
  skip_if_not("sqlite" %in% src_names)
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>%
      mutate(data = if_else(table == "t1", list(dm_for_filter_src$sqlite$t1), data))) %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("validator speaks up when something's wrong", {
  # key tracker of non-zoomed dm contains entries
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter) %>% mutate(key_tracker_zoom = list(1))) %>% validate_dm(),
    "dm_invalid"
  )

  # zoom column of `zoomed_dm` is empty
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter %>% dm_zoom_to_tbl(t1)) %>% mutate(zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
    "dm_invalid"
  )

  # key tracker of zoomed dm is empty
  expect_dm_error(
    new_dm3(dm_get_def(dm_for_filter %>% dm_zoom_to_tbl(t1)) %>% mutate(key_tracker_zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
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
      dm_zoom_to_tbl(t1) %>%
      dm_get_def() %>%
      mutate(zoom = if_else(table == "t1", list(1), NULL)), zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid"
  )

  # zoom column of a zoomed dm contains more than one entry
  expect_dm_error(
    new_dm3(dm_for_filter %>%
      dm_zoom_to_tbl(t1) %>%
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
