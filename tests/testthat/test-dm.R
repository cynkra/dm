test_that("can access tables", {
  expect_identical(tbl(cdm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_cdm_error(
    tbl(cdm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("can create dm with as_dm()", {
  test_obj_df <- as_dm(cdm_get_tables(cdm_test_obj))

  walk(
    cdm_test_obj_src, ~ expect_equivalent_dm(as_dm(cdm_get_tables(.)), test_obj_df)
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
  expect_cdm_error(
    copy_to(dm_for_filter, list(mtcars, iris)),
    "one_name_for_each_table"
  )

  expect_cdm_error(
    copy_to(dm_for_filter, letters[1:5], name = "letters"),
    "only_data_frames_supported"
  )

  expect_equivalent_dm(
    copy_to(dm_for_filter, mtcars, "car_table"),
    cdm_add_tbl(dm_for_filter, car_table = mtcars)
  )

  # copying local `tibble` to postgres `dm`
  skip_if_error(
    expect_equivalent_dm(
      copy_to(dm_for_filter_src$postgres, d1_src$df, "test_table"),
      cdm_add_tbl(dm_for_filter_src$postgres, test_table = d1_src$postgres)
      )
  )

  # copying list of postgres `tibbles` to local `dm`
  skip_if_error(
    expect_equivalent_dm(
      copy_to(dm_for_filter_src$df, list(d1_src$postgres, d2_src$postgres), c("test_table_1", "test_table_2")),
      cdm_add_tbl(dm_for_filter_src$df, test_table_1 = d1_src$df, test_table_2 = d2_src$df)
    )
  )
})

test_that("'compute.dm()' computes tables on DB", {
  db_src_names <- setdiff(src_names, c("df"))
  skip_if(is_empty(db_src_names))
  walk(
    db_src_names,
    ~expect_true({
        def <- dm_for_filter_src[[.x]] %>% cdm_filter(t1, a > 3) %>% compute() %>% cdm_get_def()
        test <- map_chr(map(def$data, sql_render), as.character)
        all(map_lgl(test, ~ !grepl("WHERE", .)))})
  )
})

test_that("some methods/functions for `zoomed_dm` work", {
  expect_identical(
    colnames(cdm_zoom_to_tbl(dm_for_filter, t1)),
    c("a", "b")
  )

  expect_identical(
    dim(cdm_zoom_to_tbl(dm_for_filter, t1)),
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
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>%
              mutate(data = if_else(table == "t1", list(dm_for_filter_src$postgres$t1), data))) %>%
      validate_dm(),
    "dm_invalid"
  )

})

test_that("validator speaks up (sqlite)", {
  skip_if_not("sqlite" %in% src_names)
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>%
              mutate(data = if_else(table == "t1", list(dm_for_filter_src$sqlite$t1), data))) %>%
      validate_dm(),
    "dm_invalid"
  )
})

test_that("validator speaks up when something's wrong", {
  # key tracker of non-zoomed dm contains entries
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>% mutate(key_tracker_zoom = list(1))) %>% validate_dm(),
    "dm_invalid")

  # zoom column of `zoomed_dm` is empty
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter %>% cdm_zoom_to_tbl(t1)) %>% mutate(zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
    "dm_invalid")

  # key tracker of zoomed dm is empty
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter %>% cdm_zoom_to_tbl(t1)) %>% mutate(key_tracker_zoom = list(NULL)), zoomed = TRUE) %>% validate_dm(),
    "dm_invalid")

  # table name is missing
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>% mutate(table = "")) %>% validate_dm(),
    "dm_invalid")

  # zoom column of un-zoomed dm contains a (nonsensical) entry
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>% mutate(zoom = list(1))) %>% validate_dm(),
    "dm_invalid")

  # zoom column of a zoomed dm contains a nonsensical entry
  expect_cdm_error(
    new_dm3(dm_for_filter %>%
              cdm_zoom_to_tbl(t1) %>%
              cdm_get_def() %>%
              mutate(zoom = if_else(table == "t1", list(1), NULL)), zoomed = TRUE) %>%
      validate_dm(),
    "dm_invalid")

  # zoom column of a zoomed dm contains more than one entry
  expect_cdm_error(
    new_dm3(dm_for_filter %>%
            cdm_zoom_to_tbl(t1) %>%
            cdm_get_def() %>%
            mutate(zoom = list(t1)), zoomed = TRUE) %>%
    validate_dm(),
    "dm_invalid")

  # data column of un-zoomed dm contains non-tibble entries
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>% mutate(data = list(1, 2, 3, 4, 5, 6))) %>% validate_dm(),
    "dm_invalid")

  # PK metadata wrong (colname doesn't exist)
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>% mutate(pks = if_else(table == "t1", vctrs::list_of(new_pk(list("z"))), pks))) %>%
      validate_dm(),
    "dm_invalid"
  )

  # FK metadata wrong (table doesn't exist)
  expect_cdm_error(
    new_dm3(cdm_get_def(dm_for_filter) %>%
              mutate(fks = if_else(table == "t3", vctrs::list_of(new_fk(table = "t8", list("z"))), fks))) %>%
      validate_dm(),
    "dm_invalid"
  )

})
