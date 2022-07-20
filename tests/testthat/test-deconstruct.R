# TODO: can probably be deleted once this feature branch is ready for a merge

# helpers ----------------------------------

test_that("`new_fks_in()` generates expected tibble", {
  expect_snapshot({
    new_fks_in(
      child_uuid = "flights-uuid",
      child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_key_cols = new_keys(list(list("faa")))
    )
  })
})

test_that("`new_fks_out()` generates expected tibble", {
  expect_snapshot({
    new_fks_out(
      child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_uuid = "airports-uuid",
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
        child_uuid = "flights-uuid",
        child_fk_cols = new_keys(list("origin", "dest")),
        parent_key_cols = new_keys(list("faa"))
      ),
      fks_out = new_fks_out(
        child_fk_cols = new_keys(list("origin", "dest")),
        parent_uuid = "airports-uuid",
        parent_key_cols = new_keys(list("faa"))
      ),
      uuid = "0a0c060f-0d01-0b03-0402-05090800070e"
    )

    keyed_get_info(keyed_tbl)
  })

  expect_equal(dm$airports, keyed_tbl, ignore_attr = TRUE)
})

test_that("dm_get_keyed_tables_impl()", {
  withr::local_seed(20220715)

  expect_snapshot({
    dm_nycflights13(cycle = TRUE) %>%
      dm_get_keyed_tables_impl() %>%
      map(keyed_get_info)
  })
})



test_that("`new_keyed_tbl()` formatting", {
  expect_snapshot({
    keyed_tbl_impl(dm_nycflights13(cycle = TRUE), "flights")
    keyed_tbl_impl(dm_nycflights13(cycle = TRUE), "airports")
    keyed_tbl_impl(dm_nycflights13(cycle = TRUE), "airlines")
  })
})

# subsetting ----------------------------------

test_that("both subsetting operators for `dm` produce the same object", {
  dm <- dm_nycflights13(cycle = TRUE)

  expect_equal(dm$airlines, dm[["airlines"]])
  expect_equal(dm[[1]], dm[["airlines"]])
})

test_that("subsetting `dm` produces `dm_keyed_tbl` objects", {
  dm <- dm_nycflights13(cycle = TRUE)

  skip("keyed = TRUE")

  expect_s3_class(dm$airlines, "dm_keyed_tbl")
  expect_s3_class(dm[[1]], "dm_keyed_tbl")
  expect_s3_class(dm[["airlines"]], "dm_keyed_tbl")
})

# constructors ----------------------------------

test_that("`dm()` and `new_dm()` can handle a list of `dm_keyed_tbl` objects", {
  dm <- dm_nycflights13(cycle = TRUE)

  y1 <- keyed_tbl_impl(dm, "weather") %>%
    mutate() %>%
    select(everything())
  y2 <- keyed_tbl_impl(dm, "airports") %>%
    mutate() %>%
    select(everything())

  expect_s3_class(y1, "dm_keyed_tbl")
  expect_s3_class(y2, "dm_keyed_tbl")

  dm_output <- dm(d1 = y1, d2 = y2)
  expect_s3_class(dm_output, "dm")

  new_dm_output <- new_dm(list(d1 = y1, d2 = y2))
  expect_s3_class(new_dm_output, "dm")

  # there shouldn't be any keys
  expect_snapshot(tbl_sum(keyed_tbl_impl(dm_output, "d1")))
  expect_snapshot(tbl_sum(keyed_tbl_impl(dm_output, "d2")))
  expect_snapshot(tbl_sum(keyed_tbl_impl(new_dm_output, "d1")))
  expect_snapshot(tbl_sum(keyed_tbl_impl(new_dm_output, "d2")))
})

test_that("`dm()` and `new_dm()` can handle a mix of tables and `dm_keyed_tbl` objects", {
  dm <- dm_nycflights13(cycle = TRUE)

  y1 <- keyed_tbl_impl(dm, "weather") %>%
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
  expect_snapshot(tbl_sum(keyed_tbl_impl(dm_output, "d1")))
  expect_snapshot(tbl_sum(keyed_tbl_impl(dm_output, "d2")))
  expect_snapshot(tbl_sum(keyed_tbl_impl(new_dm_output, "d1")))
  expect_snapshot(tbl_sum(keyed_tbl_impl(new_dm_output, "d2")))
})

test_that("`dm()` handles missing key column names gracefully", {
  dm <-
    dm(x = tibble(a = 1, b = 1), y = tibble(a = 1, b = 1)) %>%
    dm_add_pk(y, c(a, b)) %>%
    dm_add_fk(x, c(a, b), y)

  keyed <-
    dm %>%
    dm_get_tables(keyed = TRUE)

  expect_snapshot({
    dm(x = keyed$x["b"], y = keyed$y) %>%
      dm_paste()
    dm(x = keyed$x, y = keyed$y["b"]) %>%
      dm_paste()
  })
})

# joins ----------------------------------

test_that("keyed_by()", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1), y = tibble(b = 1)) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")

  expect_snapshot({
    keyed_by(x, y)
    keyed_by(y, x)
  })
})

test_that("joins without child PK", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1), y = tibble(b = 1)) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with other child PK", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1, c = 1), y = tibble(b = 1)) %>%
    dm_add_pk(x, c) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with other child PK and name conflict", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1, b = 1), y = tibble(b = 1)) %>%
    dm_add_pk(x, b) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with same child PK", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1), y = tibble(b = 1)) %>%
    dm_add_pk(x, a) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with same child PK and same name", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(b = 1), y = tibble(b = 1)) %>%
    dm_add_pk(x, b) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, b, y)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with other FK from parent", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1), y = tibble(b = 1, c = 1), z = tibble(c = 1)) %>%
    dm_add_pk(x, a) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y) %>%
    dm_add_fk(y, c, z, c)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")
  z <- keyed_tbl_impl(dm, "z")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with other FK from parent and name conflict", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1), y = tibble(b = 1, a = 1), z = tibble(a = 1)) %>%
    dm_add_pk(x, a) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y) %>%
    dm_add_fk(y, a, z, a)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")
  z <- keyed_tbl_impl(dm, "z")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with other FK from child", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1, c = 1), y = tibble(b = 1), z = tibble(c = 1)) %>%
    dm_add_pk(x, a) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y) %>%
    dm_add_fk(x, c, z, c)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")
  z <- keyed_tbl_impl(dm, "z")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("joins with other FK from child and name conflict", {
  withr::local_seed(20220715)

  dm <-
    dm(x = tibble(a = 1, b = 1), y = tibble(b = 1), z = tibble(b = 1)) %>%
    dm_add_pk(x, a) %>%
    dm_add_pk(y, b) %>%
    dm_add_fk(x, a, y) %>%
    dm_add_fk(x, b, z, b)

  x <- keyed_tbl_impl(dm, "x")
  y <- keyed_tbl_impl(dm, "y")
  z <- keyed_tbl_impl(dm, "z")

  expect_snapshot({
    keyed_build_join_spec(x, y) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(x, y)) %>%
      dm_paste(options = c("select", "keys"))
    keyed_build_join_spec(y, x) %>%
      jsonlite::toJSON(pretty = TRUE)
    dm(x, y, z, r = left_join(y, x)) %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("left join works as expected with keyed tables", {
  withr::local_seed(20220717)

  expect_snapshot({
    dm <- dm_nycflights13()
    keyed_tbl_impl(dm, "weather") %>% left_join(keyed_tbl_impl(dm, "flights"))
  })

  # results should be similar to zooming
  zd1 <- dm_zoom_to(dm, weather) %>% left_join(flights)
  zd2 <- dm_zoom_to(dm, flights) %>% left_join(weather)

  jd1 <- keyed_tbl_impl(dm, "weather") %>% left_join(keyed_tbl_impl(dm, "flights"))
  jd2 <- keyed_tbl_impl(dm, "flights") %>% left_join(keyed_tbl_impl(dm, "weather"))

  expect_equal(ncol(jd1), ncol(jd2))
  expect_equal(dim(zd2), dim(jd2))
})

# arrange ----------------------------------

test_that("arrange for keyed tables produces expected output", {
  dm <- dm_nycflights13(cycle = TRUE)

  expect_snapshot({
    keyed_tbl_impl(dm, "airlines") %>% arrange(desc(name))
  })
})

# group_by ----------------------------------

test_that("group_by for keyed tables produces expected output", {
  expect_snapshot({
    dm <- dm_nycflights13(cycle = TRUE)

    keyed_tbl_impl(dm, "flights") %>% group_by(month)

    keyed_tbl_impl(dm, "airports") %>% group_by(tzone)

    # grouping by the primary key works as well
    keyed_tbl_impl(dm, "airports") %>% group_by(faa)
  })
})

# summarize ----------------------------------

test_that("summarize for keyed tables produces expected output", {
  # FIXME: Brittle tests?
  local_options(dplyr.summarise.inform = FALSE)

  expect_snapshot({
    dm <- dm_nycflights13(cycle = TRUE)

    keyed_tbl_impl(dm, "airports") %>%
      summarise(mean_alt = mean(alt))

    keyed_tbl_impl(dm, "airports") %>%
      group_by(tzone, dst) %>%
      summarise(mean_alt = mean(alt))
  })
})


test_that("summarize for keyed tables produces same output as zooming", {
  dm <- dm_nycflights13(cycle = TRUE)

  z_summary <- dm %>%
    dm_zoom_to(flights) %>%
    group_by(month) %>%
    arrange(desc(day)) %>%
    summarize(avg_air_time = mean(air_time, na.rm = TRUE))

  k_summary <- keyed_tbl_impl(dm, "flights") %>%
    group_by(month) %>%
    arrange(desc(day)) %>%
    summarize(avg_air_time = mean(air_time, na.rm = TRUE))

  # zoomed and keyed approaches should provide same summaries
  expect_equal(dim(z_summary), dim(k_summary))
  expect_equal(z_summary$month, k_summary$month)
  expect_equal(z_summary$avg_air_time, k_summary$avg_air_time)
})

# reconstruction ----------------------------------

test_that("pks_df_from_keys_info()", {
  withr::local_seed(20220715)

  dm <- dm_nycflights13(cycle = TRUE)

  expect_snapshot({
    dm %>%
      dm_get_keyed_tables_impl() %>%
      pks_df_from_keys_info() %>%
      jsonlite::toJSON(pretty = TRUE)
  })
})

test_that("fks_df_from_keys_info()", {
  withr::local_seed(20220715)

  dm <- dm_nycflights13(cycle = TRUE)

  expect_snapshot({
    dm %>%
      dm_get_keyed_tables_impl() %>%
      fks_df_from_keys_info() %>%
      jsonlite::toJSON(pretty = TRUE)
  })
})

test_that("primary and foreign keys survive the round trip", {
  dm <- dm_nycflights13(cycle = TRUE)
  tbl <- keyed_tbl_impl(dm, "weather")
  tbl_mutate <- tbl %>% select(everything())

  dm2 <- dm(
    weather = tbl_mutate,
    airlines = keyed_tbl_impl(dm, "airlines"),
    airports = keyed_tbl_impl(dm, "airports"),
    planes = keyed_tbl_impl(dm, "planes"),
    flights = keyed_tbl_impl(dm, "flights"),
  )

  original_def <- dm_get_def(dm) %>% arrange(table)
  new_def <- dm_get_def(dm2) %>% arrange(table)

  expect_equal(original_def$pks, new_def$pks)
  expect_equal(original_def$fks, new_def$fks)
})
