test_that("insert + delete + truncate message", {
  expect_snapshot({
    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
    data

    rows_insert(data, test_db_src_frame(select = 4, where = "z"), conflict = "ignore")
    data %>% arrange(select)
  })
})

test_that("insert + delete + truncate", {
  expect_snapshot({
    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
    data

    writeLines(conditionMessage(expect_error(
      rows_insert(data, tibble(select = 4, where = "z"), conflict = "ignore")
    )))
    rows_insert(data, test_db_src_frame(select = 4, where = "z"), conflict = "ignore", in_place = FALSE)
    data %>% arrange(select)
    rows_insert(data, test_db_src_frame(select = 4, where = "z"), conflict = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 2), unmatched = "ignore", in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 2), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select", "where"), unmatched = "ignore", in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select", "where"), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = "where", unmatched = "ignore", in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = "where", unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), unmatched = "ignore", in_place = FALSE)
    data %>% arrange(select)
    rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)

    rows_truncate(data, in_place = FALSE)
    data %>% arrange(select)
    rows_truncate(data, in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("insert + delete with returning argument (#607)", {
  skip_if_src("duckdb")

  if (is_my_test_src_sqlite()) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  out <- rows_insert(target, test_db_src_frame(select = 4, where = "z"), conflict = "ignore", in_place = TRUE, returning = everything())
  expect_equal(
    dbplyr::get_returned_rows(out),
    tibble(select = 4L, where = "z", exists = NA_real_)
  )

  # Not inserting duplicates
  # Suppress Postgres warning, buglet with RETURNING after inserting empty result set
  suppressWarnings(out <- rows_insert(target, test_db_src_frame(select = 4, where = "z"), conflict = "ignore", in_place = TRUE, returning = everything()))
  expect_equal(nrow(dbplyr::get_returned_rows(out)), 0)

  expect_equal(
    rows_insert(target, test_db_src_frame(select = 5, where = "w"), conflict = "ignore", in_place = TRUE, returning = c(sl = select)) %>%
      dbplyr::get_returned_rows(),
    tibble(sl = 5L)
  )

  expect_equal(
    rows_delete(target, test_db_src_frame(where = "z"), unmatched = "ignore", in_place = TRUE, returning = select) %>%
      dbplyr::get_returned_rows(),
    tibble(select = 4L)
  )
})

test_that("insert + delete with returning argument and in_place = FALSE", {
  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_equal(
    rows_delete(target, test_db_src_frame(select = 3:4, where = "z"), in_place = FALSE, unmatched = "ignore", returning = everything()) %>%
      dbplyr::get_returned_rows(),
    tibble(select = 3L, where = NA_character_, exists = 2.5)
  )

  skip_if_src(c("df", "sqlite"))
  skip_if(packageVersion("dbplyr") > "2.1.1")
  expect_equal(
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = FALSE, returning = everything()) %>%
      dbplyr::get_returned_rows(),
    tibble(select = 4L, where = "z", exists = NA_real_)
  )
  expect_equal(
    rows_append(target, test_db_src_frame(select = 4, where = "q"), in_place = FALSE, returning = everything()) %>%
      dbplyr::get_returned_rows(),
    tibble(select = 4L, where = "q", exists = NA_real_)
  )
})

test_that("insert + delete with returning argument and in_place = FALSE, SQLite variant", {
  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  # Introduced in https://github.com/tidyverse/dbplyr/commit/ebe9a079a56522abb6f919bf42105ae05ca87951,
  # sqlite isn't type stable, perhaps the underlying query has changed in a subtle way
  skip_if_src_not(c("df", "sqlite"))
  skip_if(packageVersion("dbplyr") <= "2.1.1")

  expect_equal(
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = FALSE, returning = everything()) %>%
      dbplyr::get_returned_rows(),
    tibble(select = 4L, where = "z", exists = NA)
  )

  expect_equal(
    rows_append(target, test_db_src_frame(select = 4, where = "q"), in_place = FALSE, returning = everything()) %>%
      dbplyr::get_returned_rows(),
    tibble(select = 4L, where = "q", exists = NA)
  )
})

test_that("duckdb errors for returning argument", {
  skip_if_src_not("duckdb")

  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_snapshot_error({
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = everything())
  })
})

test_that("update", {
  expect_snapshot({
    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
    data

    suppressMessages(rows_update(data, tibble(select = 2:3, where = "w"), copy = TRUE, unmatched = "ignore", in_place = FALSE))
    suppressMessages(rows_update(data, tibble(select = 2:3), copy = TRUE, unmatched = "ignore", in_place = FALSE))
    data %>% arrange(select)

    rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where", unmatched = "ignore", in_place = FALSE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 2:3, where = "w"), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 2, where = "w", exists = 3.5), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 2:3), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where", unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("patch", {
  expect_snapshot({
    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
    data

    suppressMessages(rows_patch(data, tibble(select = 2:3, where = "patched"), copy = TRUE, unmatched = "ignore", in_place = FALSE) %>% arrange(select))
    suppressMessages(rows_patch(data, tibble(select = 2:3), copy = TRUE, unmatched = "ignore", in_place = FALSE))
    data %>% arrange(select)

    rows_patch(data, test_db_src_frame(select = 0L, where = "patched"), by = "where", unmatched = "ignore", in_place = FALSE)
    data %>% arrange(select)
    rows_patch(data, test_db_src_frame(select = 2:3, where = "patched"), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)

    data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
    rows_patch(data, test_db_src_frame(select = 2:3), unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
    rows_patch(data, test_db_src_frame(select = 0L, where = "a"), by = "where", unmatched = "ignore", in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("update with returning argument (#607)", {
  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
  y <- tibble(select = 2:4, where = "w")
  expected <- tibble(select = 2:3, where = "w", exists = c(1.5, 2.5))

  expect_equal(
    suppressMessages(
      rows_update(target, y, copy = TRUE, unmatched = "ignore", in_place = FALSE, returning = everything())
    ) %>%
      dbplyr::get_returned_rows() %>%
      arrange(select),
    expected
  )

  skip_if_src("duckdb")

  if (is_my_test_src_sqlite()) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  expect_equal(
    suppressMessages(
      rows_update(target, y, copy = TRUE, unmatched = "ignore", in_place = TRUE, returning = everything())
    ) %>%
      dbplyr::get_returned_rows() %>%
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
      rows_patch(target, y, copy = TRUE, unmatched = "ignore", in_place = FALSE, returning = everything())
    ) %>%
      dbplyr::get_returned_rows() %>%
      arrange(select),
    expected
  )

  skip_if_src("duckdb")

  if (is_my_test_src_sqlite()) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  expect_equal(
    suppressMessages(
      rows_patch(target, y, copy = TRUE, unmatched = "ignore", in_place = TRUE, returning = everything())
    ) %>%
      dbplyr::get_returned_rows() %>%
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
    rows_upsert(target, y, copy = TRUE, in_place = FALSE, returning = everything()) %>%
      dbplyr::get_returned_rows(),
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
      rows_upsert(target, y, copy = TRUE, in_place = TRUE, returning = everything())
    ) %>%
      dbplyr::get_returned_rows() %>%
      arrange(select),
    expected
  )
})
