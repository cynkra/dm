# basic tests -------------------------------------------------------------

test_that("basic test: 'group_by()'-methods work", {
  expect_equivalent_tbl(
    group_by(dm_zoomed(), e) %>% tbl_zoomed(),
    group_by(tf_2(), e)
  )

  expect_dm_error(
    group_by(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'select()'-methods work", {
  expect_equivalent_tbl(
    select(dm_zoomed(), e, a = c) %>% tbl_zoomed(),
    select(tf_2(), e, a = c)
  )

  expect_dm_error(
    select(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'relocate()'-methods work", {
  expect_equivalent_tbl(
    relocate(dm_zoomed(), e) %>% tbl_zoomed(),
    relocate(tf_2(), e)
  )

  expect_equivalent_tbl(
    relocate(dm_zoomed(), e, .after = e1) %>% tbl_zoomed(),
    relocate(tf_2(), e, .after = e1)
  )

  expect_dm_error(
    relocate(dm_for_filter()),
    "only_possible_w_zoom"
  )
})


test_that("basic test: 'rename()'-methods work", {
  expect_equivalent_tbl(
    rename(dm_zoomed(), a = c) %>% tbl_zoomed(),
    rename(tf_2(), a = c)
  )

  expect_dm_error(
    rename(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'mutate()'-methods work", {
  expect_equivalent_tbl(
    mutate(dm_zoomed(), d_2 = d * 2) %>% tbl_zoomed(),
    mutate(tf_2(), d_2 = d * 2)
  )

  expect_dm_error(
    mutate(dm_for_filter()),
    "only_possible_w_zoom"
  )
})


test_that("basic test: 'transmute()'-methods work", {
  expect_equivalent_tbl(
    transmute(dm_zoomed(), d_2 = d * 2) %>% tbl_zoomed(),
    transmute(tf_2(), d_2 = d * 2)
  )

  expect_dm_error(
    transmute(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'ungroup()'-methods work", {
  expect_equivalent_tbl(
    group_by(dm_zoomed(), e) %>% ungroup() %>% tbl_zoomed(),
    group_by(tf_2(), e) %>% ungroup()
  )

  expect_dm_error(
    ungroup(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'summarise()'-methods work", {
  expect_equivalent_tbl(
    summarise(dm_zoomed(), d_2 = mean(d, na.rm = TRUE)) %>% tbl_zoomed(),
    summarise(tf_2(), d_2 = mean(d, na.rm = TRUE))
  )

  expect_dm_error(
    summarise(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'count()'-method works", {
  expect_equivalent_tbl(
    count(dm_zoomed()) %>% tbl_zoomed(),
    count(tf_2())
  )

  expect_equivalent_tbl(
    count(dm_zoomed(), c) %>% tbl_zoomed(),
    count(tf_2(), c)
  )

  expect_equivalent_tbl(
    count(dm_zoomed(), wt = d) %>% tbl_zoomed(),
    count(tf_2(), wt = d)
  )

  expect_equivalent_tbl(
    count(dm_zoomed(), sort = TRUE) %>% tbl_zoomed(),
    count(tf_2(), sort = TRUE)
  )

  expect_equivalent_tbl(
    count(dm_zoomed(), name = "COUNT") %>% tbl_zoomed(),
    count(tf_2(), name = "COUNT")
  )

  expect_dm_error(
    count(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'tally()'-method works", {
  expect_equivalent_tbl(
    tally(dm_zoomed()) %>% tbl_zoomed(),
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
    dm_zoomed() %>%
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
    distinct(dm_zoomed(), d_new = d) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
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
    arrange(dm_zoomed(), e) %>% tbl_zoomed(),
    arrange(tf_2(), e)
  )

  # arrange within groups
  expect_equivalent_tbl(
    group_by(dm_zoomed(), e) %>% arrange(desc(d), .by_group = TRUE) %>% tbl_zoomed(),
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
    expect_equivalent_tbl(slice(dm_zoomed(), 3:6) %>% tbl_zoomed(), slice(tf_2(), 3:6)),
    "`slice.dm_zoomed\\(\\)` can potentially"
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
    mutate(dm_zoomed(), c = 1) %>% slice(1:3),
    "Keeping PK column"
  )

  expect_silent(
    expect_equivalent_tbl(
      slice(dm_zoomed(), if_else(d < 5, 1:6, 7:2), .keep_pk = FALSE) %>% tbl_zoomed(),
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
    left_join(dm_zoomed(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    left_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    inner_join(dm_zoomed(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    inner_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    semi_join(dm_zoomed(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    semi_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    anti_join(dm_zoomed(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    anti_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  # SQLite doesn't implement right join
  skip_if_src("sqlite")
  skip_if_src("maria")
  expect_equivalent_tbl(
    full_join(dm_zoomed(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    full_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    right_join(dm_zoomed(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    right_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  # these databases don't implement nest join
  skip_if_src("mssql", "postgres", "sqlite", "maria")
  # https://github.com/duckdb/duckdb/pull/3829
  skip_if_src("duckdb")
  expect_equivalent_tbl(
    nest_join(dm_zoomed(), tf_1) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
    nest_join(tf_2(), tf_1(), by = c("d" = "a"), name = "tf_1")
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work (2)", {
  # fails if RHS not linked to zoomed table and no by is given
  expect_dm_error(
    left_join(dm_zoomed(), tf_4),
    "tables_not_neighbors"
  )

  # works, if by is given
  if (is_db(my_test_src())) {
    expect_equivalent_tbl(
      left_join(dm_zoomed(), tf_4, by = c("e" = "j")) %>% dm_update_zoomed() %>% tbl_impl("tf_2"),
      left_join(tf_2(), tf_4(), by = c("e" = "j"))
    )

    expect_equivalent_tbl(
      left_join(dm_zoomed(), tf_4, by = c("e" = "j", "e1" = "j1")) %>%
        dm_update_zoomed() %>%
        tbl_impl("tf_2"),
      left_join(tf_2(), tf_4(), by = c("e" = "j", "e1" = "j1"))
    )

    # explicitly select columns from RHS using argument `select`
    expect_equivalent_tbl(
      left_join(dm_zoomed_2(), tf_2, select = c(starts_with("c"), e, e1)) %>%
        dm_update_zoomed() %>%
        tbl_impl("tf_3"),
      left_join(tf_3(), select(tf_2(), c, e, e1), by = c("f" = "e", "f1" = "e1"))
    )

    # explicitly select and rename columns from RHS using argument `select`
    expect_equivalent_tbl(
      left_join(dm_zoomed_2(), tf_2, select = c(starts_with("c"), d_new = d, e, e1)) %>%
        dm_update_zoomed() %>%
        tbl_impl("tf_3"),
      left_join(tf_3(), select(tf_2(), c, d_new = d, e, e1), by = c("f" = "e", "f1" = "e1"))
    )
  } else {
    if (utils::packageVersion("dplyr") >= "1.1.0.9000") {
      expect_equivalent_tbl(
        left_join(dm_zoomed(), tf_4, by = c("e" = "j"), relationship = "many-to-many") %>%
          dm_update_zoomed() %>%
          tbl_impl("tf_2"),
        left_join(tf_2(), tf_4(), by = c("e" = "j"), relationship = "many-to-many")
      )

      expect_equivalent_tbl(
        left_join(
          dm_zoomed(),
          tf_4,
          by = c("e" = "j", "e1" = "j1"),
          relationship = "many-to-many"
        ) %>%
          dm_update_zoomed() %>%
          tbl_impl("tf_2"),
        left_join(tf_2(), tf_4(), by = c("e" = "j", "e1" = "j1"), relationship = "many-to-many")
      )
    }

    # explicitly select columns from RHS using argument `select`
    expect_equivalent_tbl(
      left_join(dm_zoomed_2(), tf_2, select = c(starts_with("c"), e, e1), multiple = "all") %>%
        dm_update_zoomed() %>%
        tbl_impl("tf_3"),
      left_join(tf_3(), select(tf_2(), c, e, e1), by = c("f" = "e", "f1" = "e1"), multiple = "all")
    )

    # explicitly select and rename columns from RHS using argument `select`
    expect_equivalent_tbl(
      left_join(
        dm_zoomed_2(),
        tf_2,
        select = c(starts_with("c"), d_new = d, e, e1),
        multiple = "all"
      ) %>%
        dm_update_zoomed() %>%
        tbl_impl("tf_3"),
      left_join(
        tf_3(),
        select(tf_2(), c, d_new = d, e, e1),
        by = c("f" = "e", "f1" = "e1"),
        multiple = "all"
      )
    )
  }

  # a former FK-relation could not be tracked
  expect_dm_error(
    dm_zoomed() %>% select(-e) %>% left_join(tf_3),
    "fk_not_tracked"
  )

  expect_snapshot({
    "keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'"
    dm_zoomed() %>%
      left_join(tf_3, select = c(d = g, f, f1)) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    "keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'"
    dm_zoomed() %>%
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
      iris_2() %>%
        rename_at(vars(matches("^[PS]")), ~ paste0(., ".iris_2.x")) %>%
        rename(Sepal.Width = Sepal.Width.iris_2.x),
      iris_2() %>% rename_at(vars(matches("^[PS]")), ~ paste0(., ".iris_2.y")),
      by = c("key", "Sepal.Width" = "Sepal.Width.iris_2.y", "other_col")
    )
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work (3)", {
  skip_if_src("sqlite")
  # test RHS-by name collision
  if (is_db(my_test_src())) {
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
  } else {
    expect_equivalent_dm(
      dm_for_filter() %>%
        dm_rename(tf_2, "...1" = d) %>%
        dm_zoom_to(tf_3) %>%
        right_join(tf_2, multiple = "all") %>%
        dm_update_zoomed(),
      dm_for_filter() %>%
        dm_zoom_to(tf_3) %>%
        right_join(tf_2, multiple = "all") %>%
        dm_update_zoomed() %>%
        dm_rename(tf_3, "...1" = d) %>%
        dm_rename(tf_2, "...1" = d)
    )
  }
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

  expect_dm_error(
    nest_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    pack_join(dm_for_filter()),
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
    dm_zoomed() %>%
      distinct(d_new = d) %>%
      dm_update_zoomed() %>%
      dm_get_all_fks_impl(),
    dm_for_filter() %>%
      dm_get_all_fks_impl() %>%
      filter(child_table != "tf_2")
  )

  expect_identical(
    dm_zoomed() %>%
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

  # it should be possible to combine 'filter' on a dm_zoomed with all other dplyr-methods; example: 'rename'
  expect_equivalent_dm(
    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      filter(d < 6) %>%
      rename(c_new = c, d_new = d) %>%
      dm_update_zoomed() %>%
      dm_select_tbl(tf_2) %>%
      dm_rm_pk(tf_2),
    dm_for_filter()$tf_2 %>%
      filter(d < 6) %>%
      rename(c_new = c, d_new = d) %>%
      dm(tf_2 = .)
  )

  # dm_nycflights13() (with FK constraints) doesn't work on DB
  # here, FK constraints are not implemented on the DB

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(weather) %>%
      summarize(avg_wind_speed = mean(wind_speed, na.rm = TRUE)) %>%
      tbl_zoomed(),
    tbl_impl(dm_nycflights_small(), "weather") %>%
      summarize(avg_wind_speed = mean(wind_speed, na.rm = TRUE))
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
    tbl_impl(dm_nycflights_small(), "weather") %>%
      summarize(avg_wind_speed = mean(wind_speed, na.rm = TRUE))
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
    tbl_impl(dm_nycflights_small(), "weather") %>%
      mutate(time_hour_fmt = format(time_hour, tz = "UTC"))
  )
})


test_that("key tracking works for slice()", {
  skip_if_remote_src()
  expect_identical(
    slice(dm_zoomed(), if_else(d < 5, 1:6, 7:2), .keep_pk = FALSE) %>% col_tracker_zoomed(),
    set_names(c("d", "e", "e1"))
  )
  expect_message(
    expect_identical(
      slice(dm_zoomed(), if_else(d < 5, 1:6, 7:2)) %>% col_tracker_zoomed(),
      set_names(c("c", "d", "e", "e1"))
    ),
    "Keeping PK"
  )
  expect_identical(
    slice(dm_zoomed(), if_else(d < 5, 1:6, 7:2), .keep_pk = TRUE) %>% col_tracker_zoomed(),
    set_names(c("c", "d", "e", "e1"))
  )
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
      left_join(flights, multiple = "all") %>%
      nrow()
    # right_join()
    zoomed_comp_dm %>%
      right_join(flights, multiple = "all") %>%
      nrow()
    # inner_join()
    zoomed_comp_dm %>%
      inner_join(flights, multiple = "all") %>%
      nrow()
    # full_join()
    zoomed_comp_dm %>%
      full_join(flights, multiple = "all") %>%
      nrow()
    # semi_join()
    zoomed_comp_dm %>%
      semi_join(flights) %>%
      nrow()
    # anti_join()
    zoomed_comp_dm %>%
      anti_join(flights) %>%
      nrow()
    # nest_join()
    zoomed_comp_dm %>%
      nest_join(flights) %>%
      nrow()
  })
})


# dplyr 1.2.0 tests -------------------------------------------------------

test_that("basic test: 'filter_out()'-methods work", {
  skip_if_remote_src()

  expect_equivalent_tbl(
    dm_zoomed() %>%
      filter_out(d < mean(d, na.rm = TRUE)) %>%
      tbl_zoomed(),
    tf_2() %>%
      filter_out(d < mean(d, na.rm = TRUE))
  )

  expect_dm_error(
    filter_out(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'reframe()'-methods work", {
  expect_equivalent_tbl(
    dm_zoomed() %>%
      group_by(e) %>%
      reframe(d_mean = mean(d, na.rm = TRUE)) %>%
      tbl_zoomed(),
    tf_2() %>%
      group_by(e) %>%
      reframe(d_mean = mean(d, na.rm = TRUE))
  )

  expect_dm_error(
    reframe(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'cross_join()'-methods for `zoomed.dm` work", {
  skip_if_remote_src()

  expect_equivalent_tbl(
    cross_join(dm_zoomed(), tf_3) %>% tbl_zoomed(),
    cross_join(tf_2(), tf_3())
  )

  expect_dm_error(
    cross_join(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

# dm_keyed_tbl tests -------------------------------------------------------

test_that("dm_keyed_tbl methods preserve keyed class", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl <- keyed_tbl_impl(dm, "tf_2")

  expect_s3_class(filter(tbl, d > 5), "dm_keyed_tbl")
  expect_s3_class(filter_out(tbl, d > 5), "dm_keyed_tbl")
  expect_s3_class(mutate(tbl, d2 = d * 2), "dm_keyed_tbl")
  expect_s3_class(transmute(tbl, d2 = d * 2), "dm_keyed_tbl")
  expect_s3_class(select(tbl, c, d), "dm_keyed_tbl")
  expect_s3_class(relocate(tbl, e, .before = c), "dm_keyed_tbl")
  expect_s3_class(rename(tbl, c2 = c), "dm_keyed_tbl")
  expect_s3_class(distinct(tbl, e), "dm_keyed_tbl")
  expect_s3_class(arrange(tbl, desc(d)), "dm_keyed_tbl")
  expect_s3_class(slice(tbl, 1:2), "dm_keyed_tbl")
  expect_s3_class(ungroup(group_by(tbl, e)), "dm_keyed_tbl")
  expect_s3_class(count(tbl, e), "dm_keyed_tbl")
  expect_s3_class(tally(tbl), "dm_keyed_tbl")
  expect_s3_class(reframe(group_by(tbl, e), d_mean = mean(d, na.rm = TRUE)), "dm_keyed_tbl")
})

# Signature alignment tests ------------------------------------------------

test_that("dm method signatures match dplyr data.frame method signatures", {
  skip_on_cran()

  dplyr_ns <- asNamespace("dplyr")
  dm_ns <- asNamespace("dm")

  # All dplyr verbs for which we provide methods, mapped to their classes
  verbs <- c(
    "filter",
    "filter_out",
    "mutate",
    "transmute",
    "select",
    "relocate",
    "rename",
    "distinct",
    "arrange",
    "slice",
    "group_by",
    "ungroup",
    "summarise",
    "reframe",
    "count",
    "tally",
    "pull",
    "left_join",
    "right_join",
    "inner_join",
    "full_join",
    "semi_join",
    "anti_join",
    "nest_join",
    "cross_join"
  )

  for (verb in verbs) {
    df_method <- tryCatch(
      get(paste0(verb, ".data.frame"), envir = dplyr_ns),
      error = function(e) NULL
    )
    if (is.null(df_method)) {
      next
    }

    df_args <- names(formals(df_method))

    for (cls in c("dm", "dm_zoomed", "dm_keyed_tbl")) {
      method_name <- paste0(verb, ".", cls)
      dm_method <- tryCatch(
        get(method_name, envir = dm_ns),
        error = function(e) NULL
      )
      if (is.null(dm_method)) {
        next
      }

      dm_args <- names(formals(dm_method))
      missing_args <- setdiff(df_args, dm_args)
      expect_true(
        length(missing_args) == 0,
        label = paste0(
          method_name,
          " is missing args from ",
          verb,
          ".data.frame: ",
          paste(missing_args, collapse = ", ")
        )
      )
    }
  }
})

# join_by() tests ----------------------------------------------------------

test_that("zoomed joins work with join_by()", {
  skip_if_remote_src()

  # left_join with join_by() using FK column mapping (tf_2.e,e1 -> tf_3.f,f1)
  expect_equivalent_tbl(
    dm_zoomed() %>%
      left_join(tf_3, by = join_by(e == f, e1 == f1)) %>%
      tbl_zoomed(),
    left_join(tf_2(), tf_3(), by = join_by(e == f, e1 == f1))
  )

  # semi_join with join_by()
  expect_equivalent_tbl(
    dm_zoomed() %>%
      semi_join(tf_3, by = join_by(e == f, e1 == f1)) %>%
      tbl_zoomed(),
    semi_join(tf_2(), tf_3(), by = join_by(e == f, e1 == f1))
  )

  # anti_join with join_by()
  expect_equivalent_tbl(
    dm_zoomed() %>%
      anti_join(tf_3, by = join_by(e == f, e1 == f1)) %>%
      tbl_zoomed(),
    anti_join(tf_2(), tf_3(), by = join_by(e == f, e1 == f1))
  )
})

test_that("keyed joins work with join_by()", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl_2 <- keyed_tbl_impl(dm, "tf_2")
  tbl_3 <- keyed_tbl_impl(dm, "tf_3")

  result <- left_join(tbl_2, tbl_3, by = join_by(e == f, e1 == f1))
  expect_s3_class(result, "dm_keyed_tbl")
  expect_true(nrow(result) > 0)

  result <- inner_join(tbl_2, tbl_3, by = join_by(e == f, e1 == f1))
  expect_s3_class(result, "dm_keyed_tbl")
  expect_true(nrow(result) > 0)
})

# dplyr 1.2.0 compatibility tests -----------------------------------------

test_that(".by works with zoomed filter()", {
  skip_if_remote_src()

  expect_equivalent_tbl(
    dm_zoomed() %>%
      filter(d == max(d), .by = e) %>%
      tbl_zoomed(),
    tf_2() %>%
      filter(d == max(d), .by = e)
  )
})

test_that(".by works with keyed filter()", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl <- keyed_tbl_impl(dm, "tf_2")

  result <- filter(tbl, d == max(d), .by = e)
  expect_s3_class(result, "dm_keyed_tbl")

  expected <- filter(tibble::as_tibble(tbl), d == max(d), .by = e)
  expect_equal(nrow(result), nrow(expected))
})

test_that(".by works with zoomed mutate()", {
  skip_if_remote_src()

  expect_equivalent_tbl(
    dm_zoomed() %>%
      mutate(d_mean = mean(d, na.rm = TRUE), .by = e) %>%
      tbl_zoomed(),
    tf_2() %>%
      mutate(d_mean = mean(d, na.rm = TRUE), .by = e)
  )
})

test_that(".by works with keyed mutate()", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl <- keyed_tbl_impl(dm, "tf_2")

  result <- mutate(tbl, d_mean = mean(d, na.rm = TRUE), .by = e)
  expect_s3_class(result, "dm_keyed_tbl")
  expect_true("d_mean" %in% colnames(result))
})

test_that(".by works with zoomed summarise()", {
  expect_equivalent_tbl(
    dm_zoomed() %>%
      summarise(d_mean = mean(d, na.rm = TRUE), .by = e) %>%
      tbl_zoomed(),
    tf_2() %>%
      summarise(d_mean = mean(d, na.rm = TRUE), .by = e)
  )
})

test_that(".by key tracking works with zoomed summarise()", {
  expect_snapshot({
    # .by should track keys like group_by does
    dm_zoom_to(dm_for_filter(), tf_2) %>%
      summarize(d_mean = mean(d), .by = c(c, e, e1)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()

    # .by with non-key col means no keys remain
    dm_zoom_to(dm_for_filter(), tf_3) %>%
      summarize(g_list = list(g), .by = g) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys()
  })
})

test_that(".by works with keyed summarise()", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl <- keyed_tbl_impl(dm, "tf_2")

  result <- summarise(tbl, d_mean = mean(d, na.rm = TRUE), .by = e)
  expect_s3_class(result, "dm_keyed_tbl")
  expect_true("d_mean" %in% colnames(result))
})

test_that(".by works with zoomed reframe()", {
  expect_equivalent_tbl(
    dm_zoomed() %>%
      reframe(d_mean = mean(d, na.rm = TRUE), .by = e) %>%
      tbl_zoomed(),
    tf_2() %>%
      reframe(d_mean = mean(d, na.rm = TRUE), .by = e)
  )
})

test_that(".by works with keyed slice()", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl <- keyed_tbl_impl(dm, "tf_2")

  result <- slice(tbl, 1, .by = e)
  expect_s3_class(result, "dm_keyed_tbl")
  expect_true(nrow(result) > 0)
})

test_that("mutate .keep and .before/.after work with zoomed dm", {
  skip_if_remote_src()

  # .keep = "used"
  expect_equivalent_tbl(
    dm_zoomed() %>%
      mutate(d2 = d * 2, .keep = "used") %>%
      tbl_zoomed(),
    tf_2() %>%
      mutate(d2 = d * 2, .keep = "used")
  )

  # .after
  result <- dm_zoomed() %>%
    mutate(d2 = d * 2, .after = d) %>%
    tbl_zoomed()
  expected <- tf_2() %>%
    mutate(d2 = d * 2, .after = d)
  expect_equivalent_tbl(result, expected)
  expect_equal(colnames(result), colnames(expected))
})

test_that("mutate .before/.after work with keyed tbl", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl <- keyed_tbl_impl(dm, "tf_2")

  result <- mutate(tbl, d2 = d * 2, .after = d)
  expect_s3_class(result, "dm_keyed_tbl")
  d_pos <- which(colnames(result) == "d")
  d2_pos <- which(colnames(result) == "d2")
  expect_equal(d2_pos, d_pos + 1)
})

test_that("arrange .locale works with zoomed dm", {
  skip_if_remote_src()

  result <- dm_zoomed() %>%
    arrange(e1, .locale = "en") %>%
    tbl_zoomed()
  expected <- tf_2() %>%
    arrange(e1, .locale = "en")
  expect_equivalent_tbl(result, expected)
})

test_that("cross_join works with keyed tables", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl_2 <- keyed_tbl_impl(dm, "tf_2")
  tbl_3 <- keyed_tbl_impl(dm, "tf_3")

  result <- cross_join(tbl_2, tbl_3)
  expect_s3_class(result, "dm_keyed_tbl")
  expect_equal(nrow(result), nrow(tbl_2) * nrow(tbl_3))
})

test_that("filter_out works correctly with zoomed dm", {
  skip_if_remote_src()

  # filter_out should drop matching rows, keeping NAs
  expect_equivalent_tbl(
    dm_zoomed() %>%
      filter_out(d > 5) %>%
      tbl_zoomed(),
    tf_2() %>%
      filter_out(d > 5)
  )
})

test_that("filter_out works correctly with keyed tbl", {
  skip_if_remote_src()

  dm <- dm_for_filter()
  tbl <- keyed_tbl_impl(dm, "tf_2")

  result <- filter_out(tbl, d > 5)
  expect_s3_class(result, "dm_keyed_tbl")

  expected <- filter_out(tibble::as_tibble(tbl), d > 5)
  expect_equal(nrow(result), nrow(expected))
})

test_that("reframe returns any number of rows per group", {
  skip_if_remote_src()

  # reframe can return multiple rows per group
  expect_equivalent_tbl(
    dm_zoomed() %>%
      group_by(e) %>%
      reframe(d_vals = range(d, na.rm = TRUE)) %>%
      tbl_zoomed(),
    tf_2() %>%
      group_by(e) %>%
      reframe(d_vals = range(d, na.rm = TRUE))
  )
})

test_that("count .drop works with zoomed dm", {
  skip_if_remote_src()

  result <- dm_zoomed() %>%
    count(e, .drop = FALSE) %>%
    tbl_zoomed()
  expected <- tf_2() %>%
    count(e, .drop = FALSE)
  expect_equivalent_tbl(result, expected)
})
