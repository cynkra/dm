test_that("insert + truncate", {
  skip_if_local_src()
  expect_snapshot({
    data <- test_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
    data

    writeLines(conditionMessage(expect_error(
      rows_insert(data, tibble(select = 4, where = "z"))
    )))
    rows_insert(data, test_src_frame(select = 4, where = "z"))
    data %>% arrange(select)
    rows_insert(data, test_src_frame(select = 4, where = "z"), in_place = FALSE)
    data %>% arrange(select)
    rows_insert(data, test_src_frame(select = 4, where = "z"), in_place = TRUE)
    data %>% arrange(select)

    rows_truncate(data, in_place = FALSE)
    data %>% arrange(select)
    rows_truncate(data, in_place = TRUE)
    data %>% arrange(select)
  })
})

test_that("update", {
  skip_if_local_src()
  # https://github.com/duckdb/duckdb/issues/1187
  skip_if_src("duckdb")
  expect_snapshot({
    data <- test_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 + 0:2)
    data

    suppressMessages(rows_update(data, tibble(select = 2:3, where = "w"), copy = TRUE, in_place = FALSE))
    suppressMessages(rows_update(data, tibble(select = 2:3), copy = TRUE, in_place = FALSE))
    data %>% arrange(select)

    rows_update(data, test_src_frame(select = 0L, where = "a"), by = "where", in_place = FALSE)
    data %>% arrange(select)
    rows_update(data, test_src_frame(select = 2:3, where = "w"), in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_src_frame(select = 2, where = "w", exists = 3.5), in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_src_frame(select = 2:3), in_place = TRUE)
    data %>% arrange(select)
    rows_update(data, test_src_frame(select = 0L, where = "a"), by = "where", in_place = TRUE)
    data %>% arrange(select)
  })
})


# tests for compound keys -------------------------------------------------

test_that("output for compound keys", {
  skip_if_local_src()
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  expect_snapshot({
    weather_subs <- dm_nycflights_small()$weather %>% mutate(row_num = dplyr::row_number())
    weather_1 <- filter(weather_subs, row_num %in% 1:100)
    weather_2 <- filter(weather_subs, row_num %in% 101:200)
    weather_3 <- filter(weather_subs, row_num %in% 51:150)
    weather_4 <- filter(weather_subs, row_num %in% 51:100)
    rows_insert(weather_1, weather_2, by = c("origin", "time_hour"), in_place = FALSE) %>% count()
    # FIXME: COMPOUND:: this should fail, doesn't for PG
    # rows_insert(weather_1, weather_3, by = c("origin", "time_hour"), in_place = FALSE)
    rows_update(weather_1, weather_4, by = c("origin", "time_hour"), in_place = FALSE)
    # FIXME: COMPOUND:: this should fail, doesn't for PG
    # rows_update(weather_1, weather_3,  by = c("origin", "time_hour"), in_place = FALSE)
    # Not implemented for DB?
    # rows_upsert(weather_1, weather_3, by = c("origin", "time_hour"), in_place = FALSE)
  })
})
