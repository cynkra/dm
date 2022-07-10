test_that("dm() API", {
  expect_snapshot({
    dm(a = tibble(), a = tibble(), .name_repair = "unique")
    dm(a = tibble(), a = tibble(), .name_repair = "unique", .quiet = TRUE)
  })
  expect_snapshot(error = TRUE, {
    dm(a = tibble(), a = tibble())
  })
  expect_snapshot(error = TRUE, {
    dm(a = dm())
  })
})

test_that("dm() works for adding tables", {
  # is a table added?
  expect_identical(
    length(dm_get_tables(dm(dm_for_filter(), data_card_1()))),
    7L
  )

  # can I retrieve the tibble under its old name?
  expect_equivalent_tbl(
    dm(dm_for_filter(), data_card_1())[["data_card_1()"]],
    data_card_1()
  )

  # can I retrieve the tibble under a new name?
  expect_equivalent_tbl(
    dm(dm_for_filter(), test = data_card_1())[["test"]],
    data_card_1()
  )

  # use special names with :=
  expect_identical(
    names(dm(dm_for_filter(), dm := data_card_1(), repair := data_card_2())),
    c(names(dm_for_filter()), "dm", "repair")
  )

  # we accept even weird table names, as long as they are unique
  expect_equivalent_tbl(
    dm(dm_for_filter(), . = data_card_1())[["."]],
    data_card_1()
  )

  # do I avoid the warning when piping the table but setting the name?
  expect_silent(
    expect_equivalent_tbl(
      dm_for_filter() %>% dm(new_name = data_card_1()) %>% pull_tbl(new_name),
      data_card_1()
    )
  )

  # adding more than 1 table:
  # 1. Is the resulting number of tables correct?
  expect_identical(
    length(dm_get_tables(dm(dm_for_filter(), data_card_1(), data_card_2()))),
    8L
  )

  # 2. Is the resulting order of the tables correct?
  expect_identical(
    src_tbls_impl(dm(dm_for_filter(), data_card_1(), data_card_2())),
    c(src_tbls_impl(dm_for_filter()), "data_card_1()", "data_card_2()")
  )

  # Is an error thrown in case I try to give the new table an old table's name if `repair = "check_unique"`?
  expect_snapshot(error = TRUE, {
    dm(dm_for_filter(), tf_1 = data_card_1(), .name_repair = "check_unique")
  })

  # are in the default case (`repair = 'unique'`) the tables renamed (old table AND new table) according to "unique" default setting
  expect_identical(
    dm(dm_for_filter(), tf_1 = data_card_1(), .name_repair = "unique", .quiet = TRUE) %>% src_tbls_impl(),
    c("tf_1...1", "tf_2", "tf_3", "tf_4", "tf_5", "tf_6", "tf_1...7")
  )

  expect_name_repair_message(
    expect_equivalent_dm(
      dm(dm_for_filter(), tf_1 = data_card_1(), .name_repair = "unique"),
      dm_for_filter() %>%
        dm_rename_tbl(tf_1...1 = tf_1) %>%
        dm(tf_1...7 = data_card_1())
    )
  )

  # can I use dm_select_tbl(), selecting among others the new table?
  expect_silent(
    dm(dm_for_filter(), tf_7_new = tf_7()) %>% dm_select_tbl(tf_1, tf_7_new, everything())
  )

  skip_if_not_installed("dbplyr")

  # error in case table srcs don't match
  expect_dm_error(
    dm(dm_for_filter(), data_card_1_duckdb()),
    "not_same_src"
  )

  # adding tables to an empty `dm` works for all sources
  expect_equivalent_tbl(
    dm(dm(), test = data_card_1_duckdb())$test,
    data_card_1()
  )
})

test_that("dm() for adding tables with compound keys", {
  expect_snapshot({
    dm(dm_for_flatten(), res_flat = result_from_flatten()) %>% dm_paste(options = c("select", "keys"))
  })
})

test_that("dm() works for dm objects", {
  expect_equivalent_dm(
    dm(dm_for_filter()),
    dm_for_filter()
  )

  expect_equivalent_dm(
    dm(dm_for_filter(), dm_for_flatten(), dm_for_disambiguate()),
    bind_rows(
      dm_get_def(dm_for_filter()),
      dm_get_def(dm_for_flatten()),
      dm_get_def(dm_for_disambiguate())
    ) %>%
      new_dm3()
  )
})

test_that("are empty_dm() and empty ellipsis handled correctly?", {
  expect_equivalent_dm(
    dm(empty_dm()),
    empty_dm()
  )

  expect_equivalent_dm(
    dm(empty_dm(), empty_dm(), empty_dm()),
    empty_dm()
  )

  expect_equivalent_dm(
    dm(),
    empty_dm()
  )
})

test_that("errors: duplicate table names, src mismatches", {
  expect_snapshot(error = TRUE, {
    dm(dm_for_filter(), dm_for_flatten(), dm_for_filter())
  })

  skip_if_not_installed("dbplyr")
  skip_if_not_installed("duckdb")
  expect_dm_error(dm(dm_for_flatten(), dm_for_filter_duckdb()), "not_same_src")
})

test_that("auto-renaming works", {
  expect_equivalent_dm(
    expect_name_repair_message(
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter(), .name_repair = "unique")
    ),
    bind_rows(
      dm_get_def(
        dm_rename_tbl(
          dm_for_filter(),
          tf_1...1 = tf_1,
          tf_2...2 = tf_2,
          tf_3...3 = tf_3,
          tf_4...4 = tf_4,
          tf_5...5 = tf_5,
          tf_6...6 = tf_6
        )
      ),
      dm_get_def(dm_for_flatten()),
      dm_get_def(dm_rename_tbl(
        dm_for_filter(),
        tf_1...12 = tf_1,
        tf_2...13 = tf_2,
        tf_3...14 = tf_3,
        tf_4...15 = tf_4,
        tf_5...16 = tf_5,
        tf_6...17 = tf_6
      ))
    ) %>%
      new_dm3()
  )

  expect_silent(
    dm(dm_for_filter(), dm_for_flatten(), dm_for_filter(), .name_repair = "unique", .quiet = TRUE)
  )
})

test_that("test error output for src mismatches", {
  skip_if_not_installed("dbplyr")

  expect_snapshot({
    writeLines(conditionMessage(expect_error(
      dm(dm_for_flatten(), dm_for_filter_duckdb())
    )))
  })
})

test_that("output for dm() with dm", {
  expect_snapshot({
    dm()
    dm(empty_dm())
    dm(dm_for_filter()) %>% collect()
    dm(dm_for_filter(), dm_for_flatten(), dm_for_filter(), .name_repair = "unique", .quiet = TRUE) %>% collect()
  })

  expect_snapshot(error = TRUE, {
    dm(dm_for_filter(), dm_for_flatten(), dm_for_filter())
  })

  expect_snapshot({
    dm(dm_for_filter(), dm_for_flatten(), dm_for_filter(), .name_repair = "unique") %>% collect()
  })
})

test_that("output dm() for dm for compound keys", {
  expect_snapshot({
    dm(dm_for_filter(), dm_for_flatten()) %>% dm_paste(options = c("select", "keys"))
    dm(dm_for_flatten(), dm_for_filter()) %>% dm_paste(options = c("select", "keys"))
  })

  expect_snapshot({
    dm(dm_for_flatten(), dm_for_flatten(), .name_repair = "unique") %>% dm_paste(options = c("select", "keys"))
  })
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
  skip("Needs https://github.com/tidyverse/dbplyr/pull/649")

  def <-
    dm_for_filter_duckdb() %>%
    dm_filter(tf_1, a > 3) %>%
    {
      suppress_mssql_message(compute(.))
    } %>%
    dm_get_def()

  remote_names <- map(def$data, dbplyr::remote_name)
  expect_equal(lengths(remote_names), rep_along(remote_names, 1))
})

test_that("'compute.zoomed_dm()' computes tables on DB", {
  skip("Needs https://github.com/tidyverse/dbplyr/pull/649")

  zoomed_dm_for_compute <-
    dm_for_filter_duckdb() %>%
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
      new_dm3(zoomed = TRUE, validate = FALSE) %>%
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
  expect_identical(
    dm_get_con(dm_for_filter_db()),
    con_from_src_or_con(my_db_test_src())
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


test_that("str()", {
  # https://github.com/cynkra/dm/pull/542/checks?check_run_id=2506393322#step:11:88
  skip("FIXME: Unstable on GHA?")

  expect_snapshot({
    dm_for_filter() %>%
      str()

    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      str()
  })
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

test_that("glimpse.dm() works", {
  skip_if_remote_src()
  expect_snapshot({
    glimpse(empty_dm())

    # glimpse 'standard' dm object
    glimpse(dm_for_disambiguate())

    # glimpse 'standard' dm object with different width
    glimpse(dm_for_disambiguate(), width = 40)

    # option "width" inside test_that-environment should always be 80
    getOption("width")

    # # glimpse dm with long names for tables and/or columns
    glimpse(
      dm_for_disambiguate() %>%
        dm_rename(
          iris_1,
          gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd = key
        ) %>%
        dm_rename_tbl(
          gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd = iris_1
        )
    )

    # in case no primary keys are present, nothing about primary keys should be printed
    dm_nycflights13() %>%
      dm_select_tbl(weather) %>%
      dm_select(weather, -origin) %>%
      glimpse()
  })
})

test_that("glimpse.zoomed_dm() works", {
  skip_if_remote_src()
  expect_snapshot({
    # doesn't have foreign keys to print
    dm_nycflights13() %>%
      dm_zoom_to(airports) %>%
      glimpse()

    # has foreign keys to print
    dm_nycflights13() %>%
      dm_zoom_to(flights) %>%
      glimpse(width = 100)

    # if any primary key has been removed, no primary key is displayed
    dm_nycflights13() %>%
      dm_zoom_to(weather) %>%
      select(-origin) %>%
      glimpse()

    # anticipate primary keys being renamed by users
    dm_nycflights13() %>%
      dm_zoom_to(weather) %>%
      rename(origin_location = origin) %>%
      glimpse()

    # if any foreign key has been removed, corresponding composite key is not displayed
    dm_nycflights13() %>%
      dm_zoom_to(flights) %>%
      select(-carrier) %>%
      glimpse()
    dm_nycflights13() %>%
      dm_zoom_to(flights) %>%
      select(-origin) %>%
      glimpse()

    # anticipate foreign keys being renamed by users
    dm_nycflights13() %>%
      dm_zoom_to(flights) %>%
      rename(origin_location = origin) %>%
      glimpse()
  })
})
