test_that("dumma", {
  expect_snapshot({
    "dummy"
  })
})

test_that("dm_rows_insert()", {
  skip_if_not_installed("nycflights13")
  skip_if_not_installed("RSQLite")
  local_options(lifecycle_verbosity = "quiet")

  expect_snapshot({
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

    sqlite <- dbConnect(RSQLite::SQLite())

    # Target database:
    flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
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
    dbDisconnect(sqlite)
  })
})

test_that("dm_rows_update()", {
  expect_snapshot({
    # Test bad column order
    dm_filter_rearranged <-
      dm_for_filter() %>%
      dm_select(tf_2, d, everything()) %>%
      dm_select(tf_4, i, everything()) %>%
      dm_select(tf_5, l, m, everything())

    suppressMessages(dm_copy <- copy_dm_to(my_db_test_src(), dm_filter_rearranged))

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

  expect_snapshot({
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

test_that("dm_rows_append() works with autoincrement PKs and FKS for Postgres", {
  skip_if_src_not(c("postgres", "mssql"))

  con_db <- my_test_con()

  # Setup
  dm_ai_w_keys <- dm_for_autoinc_1() %>%
    dm_add_pk(t1, a, autoincrement = TRUE) %>%
    dm_add_pk(t2, c, autoincrement = TRUE) %>%
    dm_add_fk(t2, d, t1) %>%
    dm_add_fk(t3, e, t1) %>%
    dm_add_fk(t4, h, t2)

  local_dm <- dm_ai_w_keys %>%
    collect()
  dm_ai_empty_remote <- local_dm %>%
    dm_ptype() %>%
    copy_dm_to(con_db, ., temporary = FALSE)

  # Tests
  withr::defer({
    order_of_deletion <- c("t4", "t2", "t3", "t1")
    walk(
      order_of_deletion,
      ~ try(dbExecute(con_db, paste0("DROP TABLE ", dbplyr::ident_q(.x))))
    )
  })

  expect_silent(
    filled_dm <- dm_rows_append(
      dm_ai_empty_remote,
      dm_ai_w_keys,
      in_place = FALSE,
      progress = FALSE
    ) %>%
      collect()
  )

  expect_silent(
    filled_dm_in_place <- dm_rows_append(
      dm_ai_empty_remote,
      dm_ai_w_keys,
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
    }
  )
})
