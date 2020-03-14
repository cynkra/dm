test_that("can access tables", {
  expect_identical(tbl(dm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_dm_error(
    tbl(dm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("can create dm with as_dm()", {
  walk(
    dm_test_obj_src, ~ expect_equivalent_dm(as_dm(dm_get_tables(.)), dm_test_obj)
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
  walk(
    dm_for_filter_src,
    function(dm_for_filter) {
      expect_identical(
        pull_tbl(dm_for_filter, t5) %>% collect(),
        t5
      )
    }
  )

  walk(
    dm_for_filter_src,
    function(dm_for_filter) {
      expect_identical(
        dm_zoom_to(dm_for_filter, t3) %>%
          mutate(new_col = row_number() * 3) %>%
          pull_tbl() %>%
          collect(),
        mutate(t3, new_col = row_number() * 3)
      )
    }
  )

  expect_identical(
    dm_zoom_to(dm_for_filter, t1) %>%
      pull_tbl(t1),
    t1
  )

  expect_dm_error(
    dm_zoom_to(dm_for_filter, t1) %>%
      pull_tbl(t2),
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
  expect_equal(dm_for_filter[[4]], t4)

  # compare numeric subsetting and subsetting by name on all sources
  walk(
    dm_for_filter_src,
    ~ expect_equal(
      .x[["t2"]],
      .x[[2]]
    )
  )

  # check if reducing `dm` size works on all sources
  walk(
    dm_for_filter_src,
    ~ expect_equivalent_dm(
      .x[c(1, 3, 5)],
      dm_select_tbl(.x, 1, 3, 5)
    )
  )
})

test_that("subsetting for dm/zoomed_dm", {
  expect_identical(dm_for_filter$t5, t5)
  expect_identical(
    dm_zoom_to(dm_for_filter, t2)$c,
    pull(t2, c)
  )

  expect_identical(dm_for_filter[["t3"]], t3)
  expect_identical(
    dm_zoom_to(dm_for_filter, t3)[["g"]],
    pull(t3, g)
  )

  expect_identical(dm_for_filter[c("t5", "t4")], dm_select_tbl(dm_for_filter, t5, t4))
  expect_identical(
    dm_zoom_to(dm_for_filter, t3)[c("g", "f", "g")],
    t3[c("g", "f", "g")]
  )
})

test_that("methods for dm/zoomed_dm work", {
  expect_identical(length(dm_for_filter), 6L)
  expect_identical(length(dm_zoom_to(dm_for_filter, t2)), 3L)

  expect_identical(names(dm_for_filter), src_tbls(dm_for_filter))
  expect_identical(names(dm_zoom_to(dm_for_filter, t2)), colnames(t2))
})

test_that("as.list()-methods work", {
  expect_identical(
    as.list(dm_for_filter),
    list_for_filter
  )

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

  walk2(
    dm_for_filter_src,
    active_srcs_class,
    ~ expect_true(inherits(dm_get_src(.x), .y))
  )
})

test_that("dm_get_con() works", {
  expect_dm_error(
    dm_get_con(1),
    class = "is_not_dm"
  )

  expect_dm_error(
    dm_get_con(dm_for_filter),
    class = "con_only_for_dbi"
  )

  active_con_class <- semi_join(lookup, filter(active_srcs, src != "df"), by = "src") %>% pull(class_con)
  dm_for_filter_src_red <- dm_for_filter_src[!(names(dm_for_filter_src) == "df")]

  walk2(
    dm_for_filter_src_red,
    active_con_class,
    ~ expect_true(inherits(dm_get_con(.x), .y))
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
