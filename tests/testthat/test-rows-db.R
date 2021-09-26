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

test_that("insert + delete + truncate with returning argument (#607)", {
  skip_if_src("duckdb")

  if (identical(my_db_test_src(), sqlite_test_src())) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_equal(
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = quote(everything())) %>%
      get_returned_rows(),
    tibble(select = 4L, where = "z", exists = NA_real_)
  )

  expect_equal(
    expect_warning(
      rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = everything()),
      NA
    ) %>%
      get_returned_rows(),
    tibble(select = 4L, where = "z", exists = NA_real_)
  )

  expect_equal(
    rows_insert(target, test_db_src_frame(select = 4, where = "z"), in_place = TRUE, returning = quote(c(sl = select))) %>%
      get_returned_rows(),
    tibble(sl = 4L)
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
  skip_if_src("duckdb")

  if (identical(my_db_test_src(), sqlite_test_src())) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_equal(
    suppressMessages(
      rows_update(target, tibble(select = 2:3, where = "w"), copy = TRUE, in_place = TRUE, returning = quote(everything()))
    ) %>%
      get_returned_rows() %>%
      arrange(select),
    tibble(select = 2:3, where = "w", exists = c(1.5, 2.5))
  )
})

test_that("patch with returning argument (#607)", {
  skip_if_src("duckdb")

  if (identical(my_db_test_src(), sqlite_test_src())) {
    skip_if_not_installed("RSQLite", "2.2.8")
  }

  target <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)

  expect_equal(
    suppressMessages(
      rows_patch(target, tibble(select = 2:3, where = "w"), copy = TRUE, in_place = TRUE, returning = quote(everything()))
    ) %>%
      get_returned_rows() %>%
      arrange(select),
    tibble(select = 2:3, where = c("b", "w"), exists = c(1.5, 2.5))
  )
})

test_that("rows_*() checks arguments", {
  data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
  expect_snapshot_error({
    rows_insert(data, data, in_place = FALSE, returning = quote(everything()))
  })
  expect_snapshot_error({
    rows_update(data, data, in_place = FALSE, returning = quote(everything()))
  })
  expect_snapshot_error({
    rows_patch(data, data, in_place = FALSE, returning = quote(everything()))
  })
  expect_snapshot_error({
    rows_delete(data, data, in_place = FALSE, returning = quote(everything()))
  })
})
