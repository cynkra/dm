# basic tests -------------------------------------------------------------


test_that("basic test: 'group_by()'-methods work", {
  expect_equivalent_tbl(
    group_by(zoomed_dm(), e) %>% tbl_zoomed(),
    group_by(tf_2(), e)
  )

  expect_dm_error(
    group_by(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'select()'-methods work", {
  expect_equivalent_tbl(
    select(zoomed_dm(), e, a = c) %>% tbl_zoomed(),
    select(tf_2(), e, a = c)
  )

  expect_dm_error(
    select(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'relocate()'-methods work", {
  expect_equivalent_tbl(
    relocate(zoomed_dm(), e) %>% tbl_zoomed(),
    relocate(tf_2(), e)
  )

  expect_equivalent_tbl(
    relocate(zoomed_dm(), e, .after = e1) %>% tbl_zoomed(),
    relocate(tf_2(), e, .after = e1)
  )

  expect_dm_error(
    relocate(dm_for_filter()),
    "only_possible_w_zoom"
  )
})


test_that("basic test: 'rename()'-methods work", {
  expect_equivalent_tbl(
    rename(zoomed_dm(), a = c) %>% tbl_zoomed(),
    rename(tf_2(), a = c)
  )

  expect_dm_error(
    rename(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'mutate()'-methods work", {
  expect_equivalent_tbl(
    mutate(zoomed_dm(), d_2 = d * 2) %>% tbl_zoomed(),
    mutate(tf_2(), d_2 = d * 2)
  )

  expect_dm_error(
    mutate(dm_for_filter()),
    "only_possible_w_zoom"
  )
})


test_that("basic test: 'transmute()'-methods work", {
  expect_equivalent_tbl(
    transmute(zoomed_dm(), d_2 = d * 2) %>% tbl_zoomed(),
    transmute(tf_2(), d_2 = d * 2)
  )

  expect_dm_error(
    transmute(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'ungroup()'-methods work", {
  expect_equivalent_tbl(
    group_by(zoomed_dm(), e) %>% ungroup() %>% tbl_zoomed(),
    group_by(tf_2(), e) %>% ungroup()
  )

  expect_dm_error(
    ungroup(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'summarise()'-methods work", {
  expect_equivalent_tbl(
    summarise(zoomed_dm(), d_2 = mean(d, na.rm = TRUE)) %>% tbl_zoomed(),
    summarise(tf_2(), d_2 = mean(d, na.rm = TRUE))
  )

  expect_dm_error(
    summarise(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'count()'-method works", {
  expect_equivalent_tbl(
    count(zoomed_dm()) %>% tbl_zoomed(),
    count(tf_2())
  )

  expect_equivalent_tbl(
    count(zoomed_dm(), c) %>% tbl_zoomed(),
    count(tf_2(), c)
  )

  expect_equivalent_tbl(
    count(zoomed_dm(), wt = d) %>% tbl_zoomed(),
    count(tf_2(), wt = d)
  )

  expect_equivalent_tbl(
    count(zoomed_dm(), sort = TRUE) %>% tbl_zoomed(),
    count(tf_2(), sort = TRUE)
  )

  expect_equivalent_tbl(
    count(zoomed_dm(), name = "COUNT") %>% tbl_zoomed(),
    count(tf_2(), name = "COUNT")
  )

  expect_dm_error(
    count(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'tally()'-method works", {
  expect_equivalent_tbl(
    tally(zoomed_dm()) %>% tbl_zoomed(),
    tally(tf_2())
  )

  expect_dm_error(
    tally(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'filter()'-methods work", {
  skip_if_src("maria")

  expect_equivalent_tbl(
    zoomed_dm() %>%
      filter(d > mean(d, na.rm = TRUE)) %>%
      dm_update_zoomed() %>%
      tbl_impl("tf_2"),
    tf_2() %>%
      filter(d > mean(d, na.rm = TRUE))
  )
})

test_that("basic test: 'filter()'-methods work (2)", {
  expect_dm_error(
    filter(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'distinct()'-methods work", {
  expect_equivalent_tbl(
    distinct(zoomed_dm(), d_new = d) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    distinct(tf_2(), d_new = d)
  )

  expect_dm_error(
    distinct(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'arrange()'-methods work", {
  # standard arrange
  expect_equivalent_tbl(
    arrange(zoomed_dm(), e) %>% tbl_zoomed(),
    arrange(tf_2(), e)
  )

  # arrange within groups
  expect_equivalent_tbl(
    group_by(zoomed_dm(), e) %>% arrange(desc(d), .by_group = TRUE) %>% tbl_zoomed(),
    arrange(group_by(tf_2(), e), desc(d), .by_group = TRUE)
  )

  expect_dm_error(
    arrange(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'slice()'-methods work", {
  skip_if_remote_src()
  expect_message(
    expect_equivalent_tbl(slice(zoomed_dm(), 3:6) %>% tbl_zoomed(), slice(tf_2(), 3:6)),
    "`slice.zoomed_dm\\(\\)` can potentially"
  )

  # silent when no PK available
  expect_silent(
    expect_equivalent_tbl(
      dm_for_disambiguate() %>%
        dm_zoom_to(iris_3) %>%
        slice(1:3) %>%
        tbl_zoomed(),
      iris_3() %>%
        slice(1:3)
    )
  )

  # changed for #663: mutate() tracks now all cols that remain
  expect_message(
    mutate(zoomed_dm(), c = 1) %>% slice(1:3),
    "Keeping PK column"
  )

  expect_silent(
    expect_equivalent_tbl(
      slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2), .keep_pk = FALSE) %>% tbl_zoomed(),
      slice(tf_2(), if_else(d < 5, 1:6, 7:2))
    )
  )

  expect_dm_error(
    slice(dm_for_filter(), 2),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work", {
  expect_equivalent_tbl(
    left_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    left_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    inner_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    inner_join(tf_2(), tf_1(), by = c("d" = "a"))
  )


  expect_equivalent_tbl(
    semi_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    semi_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    anti_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    anti_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  # SQLite doesn't implement right join
  skip_if_src("sqlite")
  skip_if_src("maria")
  expect_equivalent_tbl(
    full_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    full_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    right_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    right_join(tf_2(), tf_1(), by = c("d" = "a"))
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work (2)", {
  # fails if RHS not linked to zoomed table and no by is given
  expect_dm_error(
    left_join(zoomed_dm(), tf_4),
    "tables_not_neighbors"
  )

  # works, if by is given
  expect_equivalent_tbl(
    left_join(zoomed_dm(), tf_4, by = c("e" = "j")) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    left_join(tf_2(), tf_4(), by = c("e" = "j"))
  )

  expect_equivalent_tbl(
    left_join(zoomed_dm(), tf_4, by = c("e" = "j", "e1" = "j1")) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    left_join(tf_2(), tf_4(), by = c("e" = "j", "e1" = "j1"))
  )

  # explicitly select columns from RHS using argument `select`
  expect_equivalent_tbl(
    left_join(zoomed_dm_2(), tf_2, select = c(starts_with("c"), e, e1)) %>% dm_update_zoomed() %>% tbl_impl("tf_3"),
    left_join(tf_3(), select(tf_2(), c, e, e1), by = c("f" = "e", "f1" = "e1"))
  )

  # explicitly select and rename columns from RHS using argument `select`
  expect_equivalent_tbl(
    left_join(zoomed_dm_2(), tf_2, select = c(starts_with("c"), d_new = d, e, e1)) %>% dm_update_zoomed() %>% tbl_impl("tf_3"),
    left_join(tf_3(), select(tf_2(), c, d_new = d, e, e1), by = c("f" = "e", "f1" = "e1"))
  )

  # a former FK-relation could not be tracked
  expect_dm_error(
    zoomed_dm() %>% select(-e) %>% left_join(tf_3),
    "fk_not_tracked"
  )

  expect_snapshot({
    "keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'"
    zoomed_dm() %>%
      left_join(tf_3, select = c(d = g, f, f1)) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    "keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'"
    zoomed_dm() %>%
      semi_join(tf_3, select = c(d = g, f, f1)) %>%
      dm_update_zoomed() %>%
      get_all_keys()
  })
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work (3)", {
  skip_if_src("maria")
  # multi-column "by" argument
  out <- expect_message_obj(
    dm_for_disambiguate() %>%
      dm_zoom_to(iris_2) %>%
      left_join(iris_2, by = c("key", "Sepal.Width", "other_col")) %>%
      tbl_zoomed()
  )
  expect_equivalent_tbl(
    out,
    left_join(
      iris_2() %>% rename_at(vars(matches("^[PS]")), ~ paste0("iris_2.x.", .)) %>% rename(Sepal.Width = iris_2.x.Sepal.Width),
      iris_2() %>% rename_at(vars(matches("^[PS]")), ~ paste0("iris_2.y.", .)),
      by = c("key", "Sepal.Width" = "iris_2.y.Sepal.Width", "other_col")
    )
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work (3)", {
  # auto-added RHS-by argument
  expect_message(expect_message(
    dm_for_disambiguate() %>%
      dm_zoom_to(iris_2) %>%
      left_join(iris_2, by = c("key", "Sepal.Width", "other_col"), select = -key) %>%
      tbl_zoomed(),
    "Using `select = c(-key, key)`.",
    fixed = TRUE
  ))

  skip_if_src("sqlite")
  # test RHS-by name collision
  expect_equivalent_dm(
    dm_for_filter() %>%
      dm_rename(tf_2, "...1" = d) %>%
      dm_zoom_to(tf_3) %>%
      right_join(tf_2) %>%
      dm_update_zoomed(),
    dm_for_filter() %>%
      dm_zoom_to(tf_3) %>%
      right_join(tf_2) %>%
      dm_update_zoomed() %>%
      dm_rename(tf_3, "...1" = d) %>%
      dm_rename(tf_2, "...1" = d)
  )
})

test_that("basic test: 'join()'-methods for `dm` throws error", {
  expect_dm_error(
    left_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    inner_join(dm_for_filter()),
    "only_possible_w_zoom"
  )


  expect_dm_error(
    semi_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    anti_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    full_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    right_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    inner_join(dm_zoom_to(dm_for_filter(), tf_1), tf_7),
    "table_not_in_dm"
  )

  skip("No nest_join() for now")
  expect_dm_error(
    nest_join(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'across' works properly", {
  expect_equivalent_tbl(
    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      mutate(across(c(1, 3), ~"C")) %>%
      pull_tbl(),
    dm_for_filter() %>%
      pull_tbl(tf_2) %>%
      mutate(across(c(1, 3), ~"C"))
  )

  expect_equivalent_tbl(
    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      summarize(across(c(c, e), ~"C")) %>%
      pull_tbl(),
    dm_for_filter() %>%
      pull_tbl(tf_2) %>%
      summarize(across(c(c, e), ~"C"))
  )

  expect_equivalent_tbl(
    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      group_by(d) %>%
      summarize(across(c(1, 3), ~"C")) %>%
      pull_tbl(),
    dm_for_filter() %>%
      pull_tbl(tf_2) %>%
      group_by(d) %>%
      summarize(across(c(1, 3), ~"C"))
  )
})

# test key tracking for all methods ---------------------------------------

# dm_for_filter(), zoomed to tf_2; PK: c; 2 outgoing FKs: d, e; no incoming FKS
zoomed_grouped_out_dm <- dm_zoom_to(dm_for_filter(), tf_2) %>% group_by(c, e, e1)

# dm_for_filter(), zoomed to tf_3; PK: f; 2 incoming FKs: tf_4$j, tf_2$e; no outgoing FKS:
zoomed_grouped_in_dm <- dm_zoom_to(dm_for_filter(), tf_3) %>% group_by(g)

test_that("key tracking works", {
  expect_snapshot({
    "rename()"

    zoomed_grouped_out_dm %>%
      rename(c_new = c) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    zoomed_grouped_out_dm %>%
      rename(e_new = e) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    # FKs should not be dropped when renaming the PK they are pointing to; tibble from `dm_get_all_fks()` shouldn't change
    zoomed_grouped_in_dm %>%
      rename(f_new = f) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    "summarize()"

    # grouped by two key cols: "c" and "e" -> these two remain
    zoomed_grouped_out_dm %>%
      summarize(d_mean = mean(d)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()

    # grouped_by non-key col means, that no keys remain
    zoomed_grouped_in_dm %>%
      summarize(g_list = list(g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()
  })
})

test_that("key tracking works (2)", {
  # https://github.com/tidyverse/dbplyr/issues/670
  skip_if_remote_src()

  expect_snapshot({
    "transmute()"

    # grouped by three key cols: "c", "e", "e1" -> these three remain
    zoomed_grouped_out_dm %>%
      transmute(d_mean = mean(d)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()
  })
})

test_that("key tracking works (3)", {
  # FKs that point to a PK that vanished, should also vanish
  expect_snapshot({
    # grouped_by non-key col means, that no keys remain
    zoomed_grouped_in_dm %>%
      transmute(g_list = list(g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()
  })
})

test_that("key tracking works (4)", {
  # FKs that point to a PK that vanished, should also vanish
  expect_snapshot({
    "mutate()"

    # grouped by three key cols: "c", "e" and "e1 -> these three remain
    zoomed_grouped_out_dm %>%
      mutate(d_mean = mean(d)) %>%
      select(-d) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()

    # grouped_by non-key col means, that only key-columns that remain in the
    # result tibble are tracked for mutate()
    zoomed_grouped_in_dm %>%
      mutate(f = paste0(g, g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()

    # grouped_by non-key col means, that only key-columns that remain in the
    # result tibble are tracked for transmute()
    zoomed_grouped_in_dm %>%
      mutate(g_new = list(g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()
  })
})

test_that("key tracking works (5)", {
  skip_if_remote_src()

  expect_snapshot({
    "chain of renames & other transformations"

    zoomed_grouped_out_dm %>%
      summarize(d_mean = mean(d)) %>%
      ungroup() %>%
      rename(e_new = e) %>%
      group_by(e_new, e1) %>%
      transmute(c = paste0(c, "_animal")) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()
  })
})

test_that("key tracking works (6)", {
  # FKs that point to a PK that vanished, should also vanish
  expect_snapshot({
    zoomed_grouped_in_dm %>%
      select(g_new = g) %>%
      get_all_keys("tf_3")
  })
})

test_that("key tracking works for distinct() and arrange()", {
  expect_identical(
    zoomed_dm() %>%
      distinct(d_new = d) %>%
      dm_update_zoomed() %>%
      dm_get_all_fks_impl(),
    dm_for_filter() %>%
      dm_get_all_fks_impl() %>%
      filter(child_table != "tf_2")
  )

  expect_identical(
    zoomed_dm() %>%
      arrange(e) %>%
      dm_update_zoomed() %>%
      dm_get_all_fks_impl(),
    dm_for_filter() %>%
      dm_get_all_fks_impl()
  )

  expect_identical(
    dm_for_flatten() %>%
      dm_zoom_to(fact) %>%
      select(dim_1_key_1, dim_1_key_2, dim_3_key, dim_2_key) %>%
      dm_update_zoomed() %>%
      dm_get_all_fks_impl(),
    dm_for_flatten() %>%
      dm_get_all_fks_impl() %>%
      filter(child_fk_cols != new_keys("dim_4_key"))
  )

  # it should be possible to combine 'filter' on a zoomed_dm with all other dplyr-methods; example: 'rename'
  expect_equivalent_dm(
    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      filter(d < 6) %>%
      rename(c_new = c, d_new = d) %>%
      dm_update_zoomed(),
    dm_for_filter() %>%
      dm_filter(tf_2, d < 6) %>%
      dm_rename(tf_2, c_new = c, d_new = d)
  )

  # dm_nycflights13() (with FK constraints) doesn't work on DB
  # here, FK constraints are not implemented on the DB
  skip_if_not_installed("dbplyr")
  skip_if_not_installed("nycflights13")

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(weather) %>%
      summarize(avg_wind_speed = mean(wind_speed, na.rm = TRUE)) %>%
      tbl_zoomed(),
    tbl_impl(dm_nycflights_small(), "weather") %>% summarize(avg_wind_speed = mean(wind_speed, na.rm = TRUE))
  )

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(weather) %>%
      transmute(celsius_temp = (temp - 32) * 5 / 9) %>%
      tbl_zoomed(),
    tbl_impl(dm_nycflights_small(), "weather") %>% transmute(celsius_temp = (temp - 32) * 5 / 9)
  )

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(weather) %>%
      summarize(avg_wind_speed = mean(wind_speed, na.rm = TRUE)) %>%
      tbl_zoomed(),
    tbl_impl(dm_nycflights_small(), "weather") %>% summarize(avg_wind_speed = mean(wind_speed, na.rm = TRUE))
  )

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(weather) %>%
      transmute(celsius_temp = (temp - 32) * 5 / 9) %>%
      tbl_zoomed(),
    tbl_impl(dm_nycflights_small(), "weather") %>% transmute(celsius_temp = (temp - 32) * 5 / 9)
  )

  # slice() doesn't work on DB and reformatting a datetime on a DB is
  # currently not possible with a mere `format()` call -> skipping; cf. #358
  skip_if_remote_src()
  # keys tracking when there are no keys to track
  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(weather) %>%
      mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
      tbl_zoomed(),
    tbl_impl(dm_nycflights_small(), "weather") %>% mutate(time_hour_fmt = format(time_hour, tz = "UTC"))
  )
})


test_that("key tracking works for slice()", {
  skip_if_remote_src()
  expect_identical(slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2), .keep_pk = FALSE) %>% col_tracker_zoomed(), set_names(c("d", "e", "e1")))
  expect_message(
    expect_identical(slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2)) %>% col_tracker_zoomed(), set_names(c("c", "d", "e", "e1"))),
    "Keeping PK"
  )
  expect_identical(slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2), .keep_pk = TRUE) %>% col_tracker_zoomed(), set_names(c("c", "d", "e", "e1")))
})


test_that("can use column as primary and foreign key", {
  f <- tibble(data_card_1 = 1:3)
  data_card_1 <- tibble(data_card_1 = 1:3)

  dm <-
    dm(f, data_card_1) %>%
    dm_add_pk(f, data_card_1) %>%
    dm_add_pk(data_card_1, data_card_1) %>%
    dm_add_fk(f, data_card_1, data_card_1)

  expect_equivalent_dm(
    dm %>%
      dm_zoom_to(f) %>%
      dm_update_zoomed(),
    dm
  )
})

test_that("'summarize_at()' etc. work", {
  skip_if_not_installed("nycflights13")

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(airports) %>%
      summarize_at(vars(lat, lon), list(mean = mean, min = min, max = max), na.rm = TRUE) %>%
      tbl_zoomed(),
    dm_nycflights_small() %>%
      pull_tbl(airports) %>%
      summarize_at(vars(lat, lon), list(mean = mean, min = min, max = max), na.rm = TRUE)
  )

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(airports) %>%
      select(3:6) %>%
      summarize_all(list(mean = mean, sum = sum), na.rm = TRUE) %>%
      tbl_zoomed(),
    dm_nycflights_small() %>%
      pull_tbl(airports) %>%
      select(3:6) %>%
      summarize_all(list(mean = mean, sum = sum), na.rm = TRUE)
  )

  skip_if_remote_src()
  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(airports) %>%
      summarize_if(is_double, list(mean = mean, sum = sum), na.rm = TRUE) %>%
      tbl_zoomed(),
    dm_nycflights_small() %>%
      pull_tbl(airports) %>%
      summarize_if(is_double, list(mean = mean, sum = sum), na.rm = TRUE)
  )
})

test_that("unique_prefix()", {
  expect_equal(unique_prefix(character()), "...")
  expect_equal(unique_prefix(c("a", "bc", "ef")), "...")
  expect_equal(unique_prefix(c("a", "bcd", "ef")), "...")
  expect_equal(unique_prefix(c("a", "....", "ef")), "....")
})


# compound tests ----------------------------------------------------------

test_that("output for compound keys", {
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  zoomed_comp_dm <-
    nyc_comp() %>%
    dm_zoom_to(weather)
  # grouped by one key col and one other col
  grouped_zoomed_comp_dm_1 <-
    zoomed_comp_dm %>%
    group_by(time_hour, wind_dir)
  # grouped by the two key cols
  grouped_zoomed_comp_dm_2 <-
    zoomed_comp_dm %>%
    group_by(time_hour, origin)

  expect_snapshot({
    # TRANSFORMATION VERBS

    # mutate()
    grouped_zoomed_comp_dm_1 %>%
      mutate(count = n()) %>%
      col_tracker_zoomed()
    grouped_zoomed_comp_dm_2 %>%
      mutate(count = n()) %>%
      col_tracker_zoomed()
    # transmute()
    grouped_zoomed_comp_dm_1 %>%
      transmute(count = n()) %>%
      dm_update_zoomed()
    grouped_zoomed_comp_dm_2 %>%
      transmute(count = n()) %>%
      dm_update_zoomed()
    # summarize()
    grouped_zoomed_comp_dm_1 %>%
      summarize(count = n()) %>%
      dm_update_zoomed()
    grouped_zoomed_comp_dm_2 %>%
      summarize(count = n()) %>%
      dm_update_zoomed()
    # select()
    zoomed_comp_dm %>%
      select(time_hour, wind_dir) %>%
      dm_update_zoomed()
    zoomed_comp_dm %>%
      select(time_hour, origin, wind_dir) %>%
      dm_update_zoomed()
    # rename()
    zoomed_comp_dm %>%
      rename(th = time_hour, wd = wind_dir) %>%
      dm_update_zoomed()
    # distinct()
    zoomed_comp_dm %>%
      distinct(origin, wind_dir) %>%
      dm_update_zoomed()
    zoomed_comp_dm %>%
      distinct(origin, wind_dir, time_hour) %>%
      dm_update_zoomed()
    # filter() (cf. #437)
    zoomed_comp_dm %>%
      filter(pressure < 1020) %>%
      dm_update_zoomed()
    # pull()
    zoomed_comp_dm %>%
      pull(origin) %>%
      unique()
    # slice()
    zoomed_comp_dm %>%
      slice(c(1:3, 5:3))
    zoomed_comp_dm %>%
      slice(c(1:3, 5:3), .keep_pk = TRUE) %>%
      col_tracker_zoomed()
    # FIXME: COMPOUND:: .keep_pk = FALSE cannot deal with compound keys ATM
    # zoomed_comp_dm %>%
    #   slice(c(1:3, 5:3), .keep_pk = FALSE) %>%
    #   get_tracked_cols()

    # JOINS

    # left_join()
    zoomed_comp_dm %>%
      left_join(flights) %>%
      nrow()
    # right_join()
    zoomed_comp_dm %>%
      right_join(flights) %>%
      nrow()
    # inner_join()
    zoomed_comp_dm %>%
      inner_join(flights) %>%
      nrow()
    # full_join()
    zoomed_comp_dm %>%
      full_join(flights) %>%
      nrow()
    # semi_join()
    zoomed_comp_dm %>%
      semi_join(flights) %>%
      nrow()
    # anti_join()
    zoomed_comp_dm %>%
      anti_join(flights) %>%
      nrow()
  })
})
