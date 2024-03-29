test_that("dumma", {
  expect_snapshot({
    "dummy"
  })
})

test_that("dm_rows_insert()", {
  skip_if_not_installed("RSQLite")
  local_options(lifecycle_verbosity = "quiet")

  # Entire dataset with all dimension tables populated
  # with flights and weather data truncated:
  flights_init <-
    dm_nycflights13() %>%
    dm_zoom_to(flights) %>%
    filter(FALSE) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(weather) %>%
    filter(FALSE) %>%
    dm_update_zoomed()

  # Must use SQLite because other databases have strict foreign key constraints
  sqlite <- DBI::dbConnect(RSQLite::SQLite())

  # Target database:
  flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)

  expect_snapshot({
    print(dm_nrow(flights_sqlite))

    # First update:
    flights_hour10 <-
      dm_nycflights13() %>%
      dm_select_tbl(flights, weather) %>%
      dm_zoom_to(flights) %>%
      filter(month == 1, day == 10, hour == 10) %>%
      dm_update_zoomed() %>%
      dm_zoom_to(weather) %>%
      filter(month == 1, day == 10, hour == 10) %>%
      dm_update_zoomed()
    print(dm_nrow(flights_hour10))

    # Copy to temporary tables on the target database:
    flights_hour10_sqlite <- copy_dm_to(sqlite, flights_hour10)

    # Dry run by default:
    out <- dm_rows_append(flights_sqlite, flights_hour10_sqlite)
    print(dm_nrow(flights_sqlite))

    # Explicitly request persistence:
    dm_rows_append(flights_sqlite, flights_hour10_sqlite, in_place = TRUE)
    print(dm_nrow(flights_sqlite))

    # Second update:
    flights_hour11 <-
      dm_nycflights13() %>%
      dm_select_tbl(flights, weather) %>%
      dm_zoom_to(flights) %>%
      filter(month == 1, day == 10, hour == 11) %>%
      dm_update_zoomed() %>%
      dm_zoom_to(weather) %>%
      filter(month == 1, day == 10, hour == 11) %>%
      dm_update_zoomed()

    # Copy to temporary tables on the target database:
    flights_hour11_sqlite <- copy_dm_to(sqlite, flights_hour11)

    # Explicit dry run:
    flights_new <- dm_rows_append(
      flights_sqlite,
      flights_hour11_sqlite,
      in_place = FALSE
    )
    print(dm_nrow(flights_new))
    print(dm_nrow(flights_sqlite))

    # Check for consistency before applying:
    flights_new %>%
      dm_examine_constraints()

    # Apply:
    dm_rows_append(flights_sqlite, flights_hour11_sqlite, in_place = TRUE)
    print(dm_nrow(flights_sqlite))

    # Disconnect
    DBI::dbDisconnect(sqlite)
  })
})

test_that("dm_rows_update()", {
  # Test bad column order
  dm_filter_rearranged <-
    dm_for_filter() %>%
    dm_select(tf_2, d, everything()) %>%
    dm_select(tf_4, i, everything()) %>%
    dm_select(tf_5, l, m, everything())

  dm_copy <- suppressMessages(copy_dm_to(my_db_test_src(), dm_filter_rearranged))

  dm_update_local <- dm(
    tf_1 = tibble(
      a = 2L,
      b = "q"
    ),
    tf_4 = tibble(
      h = "e",
      i = "sieben",
    ),
    tf_5 = tibble(
      k = 3L,
      ww = 3,
    ),
  )

  dm_update_copy <- suppressMessages(copy_dm_to(my_db_test_src(), dm_update_local))

  expect_snapshot({
    dm_copy %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      dm_rows_update(dm_update_copy) %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      dm_rows_update(dm_update_copy, in_place = FALSE) %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      dm_get_tables() %>%
      map(arrange_all)

    dm_copy %>%
      dm_rows_update(dm_update_copy, in_place = TRUE)

    dm_copy %>%
      dm_get_tables() %>%
      map(arrange_all)
  })
})

test_that("dm_rows_truncate()", {
  local_options(lifecycle_verbosity = "warning")

  suppressMessages(dm_copy <- copy_dm_to(my_db_test_src(), dm_for_filter()))

  dm_truncate_local <- dm(
    tf_2 = tibble(
      c = c("worm"),
      d = 10L,
    ),
    tf_5 = tibble(
      k = 3L,
      m = "tree",
    ),
  )

  dm_truncate_copy <- suppressMessages(copy_dm_to(my_db_test_src(), dm_truncate_local))

  expect_snapshot({
    dm_copy %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      dm_rows_truncate(dm_truncate_copy) %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      dm_rows_truncate(dm_truncate_copy, in_place = FALSE) %>%
      pull_tbl(tf_2) %>%
      arrange_all()

    dm_copy %>%
      dm_get_tables() %>%
      map(arrange_all)

    dm_copy %>%
      dm_rows_truncate(dm_truncate_copy, in_place = TRUE)

    dm_copy %>%
      dm_get_tables() %>%
      map(arrange_all)
  })
})


# tests for compound keys -------------------------------------------------

test_that("output for compound keys", {
  skip("COMPOUND")
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot({
    target_dm <- dm_filter(nyc_comp(), weather, pressure > 1010) %>% dm_apply_filters()
    insert_dm <-
      dm_filter(nyc_comp(), weather, pressure <= 1010) %>%
      dm_apply_filters() %>%
      dm_select_tbl(flights, weather)
    dm_rows_insert(target_dm, insert_dm, in_place = FALSE)
    dm_rows_truncate(nyc_comp(), insert_dm, in_place = FALSE)
  })
})


# tests for autoincrement PKs ---------------------------------------------

test_that("dm_rows_append() works with autoincrement PKs and FKS for selected DBs", {
  skip_if_src_not(c("postgres", "mssql", "sqlite"))

  con_db <- my_test_con()

  # Setup
  dm_ai_w_keys <-
    dm_for_autoinc_1() %>%
    dm_add_pk(t1, a, autoincrement = TRUE) %>%
    dm_add_pk(t2, c, autoincrement = TRUE) %>%
    dm_add_pk(t4, g, autoincrement = TRUE) %>%
    dm_add_fk(t2, d, t1) %>%
    dm_add_fk(t3, e, t1) %>%
    dm_add_fk(t4, h, t2)

  local_dm <-
    dm_ai_w_keys %>%
    collect()

  withr::defer({
    order_of_deletion <- c("t4", "t2", "t3", "t1")
    walk(
      order_of_deletion,
      ~ try(DBI::dbExecute(con_db, paste0("DROP TABLE ", .x)))
    )
  })

  dm_ai_empty_remote <-
    local_dm %>%
    dm_ptype() %>%
    copy_dm_to(con_db, ., temporary = FALSE)

  # Tests
  dm_ai_insert <-
    dm_for_autoinc_1() %>%
    # Remove one PK column, only provided by database
    dm_select(t4, -g) %>%
    dm_zoom_to(t3) %>%
    filter(0L == 1L) %>%
    dm_update_zoomed()

  expect_silent(
    filled_dm <- dm_rows_append(
      dm_ai_empty_remote,
      dm_ai_insert,
      in_place = FALSE,
      progress = FALSE
    ) %>%
      collect()
  )

  expect_silent(
    filled_dm_in_place <- dm_rows_append(
      dm_ai_empty_remote,
      dm_ai_insert,
      in_place = TRUE,
      progress = FALSE
    ) %>%
      collect()
  )

  expect_silent(
    filled_dm_in_place_twice <- dm_rows_append(
      dm_ai_empty_remote,
      dm_ai_insert,
      in_place = TRUE,
      progress = FALSE
    ) %>%
      collect()
  )

  expect_snapshot(
    variant = my_test_src_name,
    {
      local_dm$t1
      local_dm$t2
      local_dm$t3
      local_dm$t4
      filled_dm$t1
      filled_dm$t2
      filled_dm$t3
      filled_dm$t4
      filled_dm_in_place$t1
      filled_dm_in_place$t2
      filled_dm_in_place$t3
      filled_dm_in_place$t4
      filled_dm_in_place_twice$t1
      filled_dm_in_place_twice$t2
      filled_dm_in_place_twice$t3
      filled_dm_in_place_twice$t4
    }
  )
})


test_that("dm_rows_append() works with autoincrement PKs and FKS locally", {
  skip_if_remote_src()

  # Setup
  local_dm <-
    dm_for_autoinc_1() %>%
    dm_add_pk(t1, a, autoincrement = TRUE) %>%
    dm_add_pk(t2, c, autoincrement = TRUE) %>%
    dm_add_pk(t4, g, autoincrement = TRUE) %>%
    dm_add_fk(t2, d, t1) %>%
    dm_add_fk(t3, e, t1) %>%
    dm_add_fk(t4, h, t2)

  dm_ai_empty <-
    local_dm %>%
    dm_ptype()

  # Corner case: empty + empty = empty
  expect_identical(
    expect_silent(dm_rows_append(
      dm_ai_empty,
      dm_ai_empty,
      in_place = FALSE,
      progress = FALSE
    )),
    dm_ai_empty
  )

  # Tests
  dm_ai_insert <-
    dm_for_autoinc_1() %>%
    # Remove one PK column, only provided by local logic
    dm_select(t4, -g) %>%
    dm_zoom_to(t3) %>%
    filter(0L == 1L) %>%
    dm_update_zoomed()

  expect_silent(
    filled_dm <- dm_rows_append(
      dm_ai_empty,
      dm_ai_insert,
      in_place = FALSE,
      progress = FALSE
    )
  )

  # Corner case: data + empty = data
  expect_identical(
    expect_silent(dm_rows_append(
      filled_dm,
      dm_ai_empty,
      in_place = FALSE,
      progress = FALSE
    )),
    filled_dm
  )

  expect_error(
    dm_rows_append(
      dm_ai_empty,
      dm_ai_insert,
      in_place = TRUE,
      progress = FALSE
    )
  )

  expect_silent(
    filled_twice_dm <- dm_rows_append(
      filled_dm,
      dm_ai_insert,
      in_place = FALSE,
      progress = FALSE
    )
  )

  expect_snapshot(
    variant = my_test_src_name,
    {
      local_dm$t1
      local_dm$t2
      local_dm$t3
      local_dm$t4
      filled_dm$t1
      filled_dm$t2
      filled_dm$t3
      filled_dm$t4
      filled_twice_dm$t1
      filled_twice_dm$t2
      filled_twice_dm$t3
      filled_twice_dm$t4
    }
  )
})
