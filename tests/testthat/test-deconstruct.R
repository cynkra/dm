# TODO: can probably be deleted once this feature branch is ready for a merge

# helpers ----------------------------------

test_that("`new_fks_in()` generates expected tibble", {
  expect_snapshot({
    new_fks_in(
      child_table = "flights",
      child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_key_cols = new_keys(list(list("faa")))
    )
  })
})

test_that("`new_fks_out()` generates expected tibble", {
  expect_snapshot({
    new_fks_out(
      child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_table = "airports",
      parent_key_cols = new_keys(list(list("faa")))
    )
  })
})

test_that("`new_keyed_tbl()` generates expected output", {
  expect_snapshot({
    dm <- dm_nycflights13(cycle = TRUE)

    # should look similar to `dm_get_all_fks_impl(dm, "airports")`
    keyed_tbl <- new_keyed_tbl(
      x = dm$airports,
      pk = "faa",
      fks_in = new_fks_in(
        child_table = "flights",
        child_fk_cols = new_keys(list("origin", "dest")),
        parent_key_cols = new_keys(list("faa"))
      ),
      fks_out = new_fks_out(
        child_fk_cols = new_keys(list("origin", "dest")),
        parent_table = "airports",
        parent_key_cols = new_keys(list("faa"))
      ),
      uuid = "0a0c060f-0d01-0b03-0402-05090800070e"
    )

    keyed_get_info(keyed_tbl)
  })

  expect_equal(dm$airports, keyed_tbl, ignore_attr = TRUE)
})

test_that("`new_keyed_tbl()` formatting", {
  expect_snapshot({
    dm_nycflights13()$flights
    dm_nycflights13()$airports
    dm_nycflights13(cycle = TRUE)$airports
  })
})

# subsetting ----------------------------------

test_that("both subsetting operators for `dm` produce the same object", {
  dm <- dm_nycflights13()

  expect_equal(dm$airlines, dm[["airlines"]])
  expect_equal(dm[[1]], dm[["airlines"]])
})

test_that("subsetting `dm` produces `dm_keyed_tbl` objects", {
  dm <- dm_nycflights13()

  expect_s3_class(dm$airlines, "dm_keyed_tbl")
  expect_s3_class(dm[[1]], "dm_keyed_tbl")
  expect_s3_class(dm[["airlines"]], "dm_keyed_tbl")
})

# constructors ----------------------------------

test_that("`dm()` and `new_dm()` can handle a list of `dm_keyed_tbl` objects", {
  dm <- dm_nycflights13()

  y1 <- dm$weather %>%
    mutate() %>%
    select(everything())
  y2 <- dm$airports %>%
    mutate() %>%
    select(everything())

  expect_s3_class(y1, "dm_keyed_tbl")
  expect_s3_class(y2, "dm_keyed_tbl")

  dm_output <- dm(d1 = y1, d2 = y2)
  expect_s3_class(dm_output, "dm")

  new_dm_output <- new_dm(list(d1 = y1, d2 = y2))
  expect_s3_class(new_dm_output, "dm")

  # there shouldn't be any keys
  expect_snapshot(tbl_sum(dm_output$d1))
  expect_snapshot(tbl_sum(dm_output$d2))
  expect_snapshot(tbl_sum(new_dm_output$d1))
  expect_snapshot(tbl_sum(new_dm_output$d2))

  # included tables should have the same dimensions as the original tables
  expect_equal(dim(dm_output$d1), dim(dm[["weather"]]))
  expect_equal(dim(dm_output$d2), dim(dm[["airports"]]))
  expect_equal(dim(new_dm_output$d1), dim(dm[["weather"]]))
  expect_equal(dim(new_dm_output$d2), dim(dm[["airports"]]))
})

test_that("`dm()` and `new_dm()` can handle a mix of tables and `dm_keyed_tbl` objects", {
  dm <- dm_nycflights13()

  y1 <- dm$weather %>%
    mutate() %>%
    select(everything())
  y2 <- nycflights13::airports

  expect_s3_class(y1, "dm_keyed_tbl")
  expect_s3_class(y2, "tbl_df")

  dm_output <- dm(d1 = y1, d2 = y2)
  expect_s3_class(dm_output, "dm")

  new_dm_output <- new_dm(list(d1 = y1, d2 = y2))
  expect_s3_class(new_dm_output, "dm")

  # there shouldn't be any keys
  expect_snapshot(tbl_sum(dm_output$d1))
  expect_snapshot(tbl_sum(dm_output$d2))
  expect_snapshot(tbl_sum(new_dm_output$d1))
  expect_snapshot(tbl_sum(new_dm_output$d2))

  # included tables should have the same dimensions as the original tables
  expect_equal(dim(dm_output$d1), dim(dm[["weather"]]))
  expect_equal(dim(dm_output$d2), dim(y2))
  expect_equal(dim(new_dm_output$d1), dim(dm[["weather"]]))
  expect_equal(dim(new_dm_output$d2), dim(y2))
})

# joins ----------------------------------

test_that("joins work as expected with keyed tables", {
  dm <- dm_nycflights13()

  # results should be similar to zooming
  zd1 <- dm_zoom_to(dm, airports) %>% left_join(flights)
  zd2 <- dm_zoom_to(dm, flights) %>% left_join(airports)

  jd1 <- dm$weather %>% left_join(dm$flights)
  jd2 <- dm$flights %>% left_join(dm$weather)

  expect_equal(ncol(jd1), ncol(jd2))
  expect_equal(keyed_get_info(dm$weather), keyed_get_info(jd1))
  expect_equal(keyed_get_info(dm$flights), keyed_get_info(jd2))

  # FIXME: need to disambiguate columns before the number of columns can match
  # expect_equal(dim(zd2), dim(jd2))
})

# group_by ----------------------------------

test_that("group_by for keyed tables produces expected output", {
  dm <- dm_nycflights13()

  expect_snapshot({
    class(dm$flights %>% group_by(month))
  })

  expect_snapshot({
    tbl_sum(dm$flights %>% group_by(month))
  })

  expect_snapshot({
    dm$flights %>% group_by(month)
  })
})

# summarize ----------------------------------

test_that("summarize for keyed tables produces expected output", {
  expect_snapshot({
    dm <- dm_nycflights13()

    dm$flights %>%
      group_by(month) %>%
      arrange(desc(day)) %>%
      summarise(avg_air_time = mean(air_time, na.rm = TRUE))
  })
})


test_that("summarize for keyed tables produces same output as zooming", {
  dm <- dm_nycflights13()

  z_summary <- dm %>%
    dm_zoom_to(flights) %>%
    group_by(month) %>%
    arrange(desc(day)) %>%
    summarize(avg_air_time = mean(air_time, na.rm = TRUE))

  k_summary <- dm$flights %>%
    group_by(month) %>%
    arrange(desc(day)) %>%
    summarize(avg_air_time = mean(air_time, na.rm = TRUE))

  # zoomed and keyed approaches should provide same summaries
  expect_equal(dim(z_summary), dim(k_summary))
  expect_equal(z_summary$month, k_summary$month)
  expect_equal(z_summary$avg_air_time, k_summary$avg_air_time)
})
