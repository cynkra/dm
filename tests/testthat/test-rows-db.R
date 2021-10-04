test_that("insert + delete + truncate", {
  expect_snapshot({
    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
    data

    writeLines(conditionMessage(expect_error(
      rows_insert(data, tibble(select = 4, where = "z"))
    )))
    rows_insert(data, test_db_src_frame(select = 4, where = "z"))
    data %>% arrange(select)
    rows_insert(data, test_db_src_frame(select = 4, where = "z"), in_place = FALSE)
    data %>% arrange(select)
    rows_insert(data, test_db_src_frame(select = 4, where = "z"), in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 2), in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 2), in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select", "where"), in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select", "where"), in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = "where", in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = "where", in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), in_place = TRUE)
    data %>% arrange(select)

    rows_truncate(data, in_place = FALSE)
    data %>% arrange(select)
    rows_truncate(data, in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("insert respects `duplicates = ignore`", {
  data <- test_db_src_frame(
    select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2,
    .unique_indexes = list("select", "where")
  )

  expect_snapshot({
    rows_insert(data, test_db_src_frame(select = 2L), in_place = FALSE, duplicates = "ignore")
    rows_insert(data, test_db_src_frame(select = 4L), in_place = FALSE, duplicates = "ignore")
    rows_insert(data, test_db_src_frame(select = 2L, where = "a"), in_place = FALSE, duplicates = "ignore", by = "where")
    rows_insert(data, test_db_src_frame(select = 2L, where = "d"), in_place = FALSE, duplicates = "ignore", by = "where")
    data %>% arrange(select)
  })

  skip_if_src("mssql")
  expect_snapshot({
    rows_insert(data, test_db_src_frame(select = 2L), in_place = TRUE, duplicates = "ignore")
    data %>% arrange(select)
    rows_insert(data, test_db_src_frame(select = 4L), in_place = TRUE, duplicates = "ignore")
    data %>% arrange(select)
    rows_insert(data, test_db_src_frame(select = 5L, where = "a"), in_place = TRUE, duplicates = "ignore", by = "where")
    data %>% arrange(select)
    rows_insert(data, test_db_src_frame(select = 5L, where = "d"), in_place = TRUE, duplicates = "ignore", by = "where")
    data %>% arrange(select)
  })
})

test_that("insert + delete with returning argument (#607)", {
  skip_if_src("duckdb")

  if (is_my_test_src_sqlite()) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_equal(
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = quote(everything())) %>%
      get_returned_rows(),
    tibble(select = 4L, where = "z", exists = NA_real_)
  )

  expect_warning(
    out <- rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = everything()),
    "returning"
  )
  expect_equal(
    get_returned_rows(out),
    tibble(select = 4L, where = "z", exists = NA_real_)
  )

  expect_equal(
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = quote(c(sl = select))) %>%
      get_returned_rows(),
    tibble(sl = 4L)
  )
})

test_that("insert + delete with returning argument and in_place = FALSE", {
  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_equal(
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = FALSE, returning = quote(everything())) %>%
      get_returned_rows(),
    tibble(select = 4L, where = "z", exists = NA_real_)
  )

  expect_equal(
    rows_delete(target, test_db_src_frame(select = 3:4, where = "z"), in_place = FALSE, returning = quote(everything())) %>%
      get_returned_rows(),
    tibble(select = 3L, where = NA_character_, exists = 2.5)
  )
})

test_that("duckdb errors for returning argument", {
  skip_if_src_not("duckdb")

  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_snapshot_error({
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = quote(everything()))
  })
})

test_that("update", {
  expect_snapshot({
    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
    data

    suppressMessages(rows_update(data, tibble(select = 2:3, where = "w"), copy = TRUE, in_place = FALSE))
    suppressMessages(rows_update(data, tibble(select = 2:3), copy = TRUE, in_place = FALSE))
    data %>% arrange(select)

    rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where", in_place = FALSE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 2:3, where = "w"), in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 2, where = "w", exists = 3.5), in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 2:3), in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where", in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("patch", {
  expect_snapshot({
    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
    data

    suppressMessages(rows_patch(data, tibble(select = 2:3, where = "patched"), copy = TRUE, in_place = FALSE) %>% arrange(select))
    suppressMessages(rows_patch(data, tibble(select = 2:3), copy = TRUE, in_place = FALSE))
    data %>% arrange(select)

    rows_patch(data, test_db_src_frame(select = 0L, where = "patched"), by = "where", in_place = FALSE)
    data %>% arrange(select)
    rows_patch(data, test_db_src_frame(select = 2:3, where = "patched"), in_place = TRUE)
    data %>% arrange(select)

    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
    rows_patch(data, test_db_src_frame(select = 2:3), in_place = TRUE)
    data %>% arrange(select)
    rows_patch(data, test_db_src_frame(select = 0L, where = "a"), by = "where", in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("update with returning argument (#607)", {
  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
  y <- tibble(select = 2:4, where = "w")
  expected <- tibble(select = 2:3, where = "w", exists = c(1.5, 2.5))

  expect_equal(
    suppressMessages(
      rows_update(target, y, copy = TRUE, in_place = FALSE, returning = quote(everything()))
    ) %>%
      get_returned_rows() %>%
      arrange(select),
    expected
  )

  skip_if_src("duckdb")

  if (is_my_test_src_sqlite()) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  expect_equal(
    suppressMessages(
      rows_update(target, y, copy = TRUE, in_place = TRUE, returning = quote(everything()))
    ) %>%
      get_returned_rows() %>%
      arrange(select),
    expected
  )
})

test_that("patch with returning argument (#607)", {
  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
  y <- tibble(select = 2:4, where = "w")
  expected <- tibble(select = 2:3, where = c("b", "w"), exists = c(1.5, 2.5))

  expect_equal(
    suppressMessages(
      rows_patch(target, y, copy = TRUE, in_place = FALSE, returning = quote(everything()))
    ) %>%
      get_returned_rows() %>%
      arrange(select),
    expected
  )

  skip_if_src("duckdb")

  if (is_my_test_src_sqlite()) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  expect_equal(
    suppressMessages(
      rows_patch(target, y, copy = TRUE, in_place = TRUE, returning = quote(everything()))
    ) %>%
      get_returned_rows() %>%
      arrange(select),
    expected
  )
})

test_that("upsert", {
  # only seems to work with SQL Server 2019, not with 2017 used in our CI
  # so let's just skip it for now
  skip_if_src("duckdb", "mssql")

  expect_snapshot({
    data <- test_db_src_frame(
      select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2,
      .unique_indexes = list("select", "where")
    )
    data

    rows_upsert(data, tibble(select = 2:4, where = c("x", "y", "z")), copy = TRUE, in_place = FALSE)
    rows_upsert(data, tibble(select = 2:4), copy = TRUE, in_place = FALSE)
    data %>% arrange(select)
    rows_upsert(data, test_db_src_frame(select = 0L, where = c("a", "d")), by = "where", in_place = FALSE)
    data %>% arrange(select)

    rows_upsert(data, test_db_src_frame(select = 2:4, where = c("x", "y", "z")), in_place = TRUE)
    data %>% arrange(select)
    rows_upsert(data, test_db_src_frame(select = 4:5, where = c("o", "p"), exists = 3.5), in_place = TRUE)
    data %>% arrange(select)
    rows_upsert(data, test_db_src_frame(select = 2:3), in_place = TRUE)
    data %>% arrange(select)
    rows_upsert(data, test_db_src_frame(select = 0L, where = "a"), by = "where", in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("upsert errors for duckdb", {
  skip_if_src_not("duckdb")

  target <- test_db_src_frame(
    select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2,
    .unique_indexes = list("select", "where")
  )

  # TODO remove `suppressWarnings()` when `dplyr::rows_*()` get argument `returning`
  expect_snapshot_error(
    suppressWarnings(rows_upsert(target, tibble(select = 2:4, where = c("x", "y", "z")), copy = TRUE, in_place = TRUE))
  )
})

test_that("upsert with returning argument (#607)", {
  target <- test_db_src_frame(
    select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2,
    .unique_indexes = list("select", "where"),
    # TODO remove this hack
    # hack needed because RETURNING doesn't work correctly for temporary tables in SQLite
    # https://github.com/cynkra/dm/pull/616#issuecomment-920624883
    .temporary = !is_my_test_src_sqlite()
  )

  y <- tibble(select = 2:4, where = c("x", "y", "z"))
  expected <- tibble(select = 2:4, where = c("x", "y", "z"), exists = c(1.5, 2.5, NA))

  expect_equal(
    rows_upsert(target, y, copy = TRUE, in_place = FALSE, returning = quote(everything())) %>%
      get_returned_rows(),
    expected
  )

  # only seems to work with SQL Server 2019, not with 2017 used in our CI
  # so let's just skip it for now
  skip_if_src("duckdb", "mssql")

  if (is_my_test_src_sqlite()) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  expect_equal(
    suppressMessages(
      rows_upsert(target, y, copy = TRUE, in_place = TRUE, returning = quote(everything()))
    ) %>%
      get_returned_rows() %>%
      arrange(select),
    expected
  )
})
