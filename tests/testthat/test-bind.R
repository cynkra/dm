test_that("dm_bind() works?", {
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    dm_bind(dm_for_filter()),
    dm_for_filter()
  )

  expect_equivalent_dm(
    dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_disambiguate()),
    bind_rows(
      dm_get_def(dm_for_filter()),
      dm_get_def(dm_for_flatten()),
      dm_get_def(dm_for_disambiguate())
    ) %>%
      new_dm3()
  )
})

test_that("are empty_dm() and empty ellipsis handled correctly?", {
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    dm_bind(empty_dm()),
    empty_dm()
  )

  expect_equivalent_dm(
    dm_bind(empty_dm(), empty_dm(), empty_dm()),
    empty_dm()
  )

  expect_equivalent_dm(
    dm_bind(),
    empty_dm()
  )
})

test_that("errors: duplicate table names, src mismatches", {
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot(error = TRUE, {
    dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter())
  })
})

test_that("errors: src mismatches", {
  local_options(lifecycle_verbosity = "quiet")

  skip_if_not_installed("dbplyr")
  skip_if_not_installed("duckdb")
  skip_if_not(getRversion() >= "4.0")
  expect_dm_error(dm_bind(dm_for_flatten(), dm_for_filter_duckdb()), "not_same_src")
})

test_that("auto-renaming works", {
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    expect_name_repair_message(
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique")
    ),
    bind_rows(
      dm_get_def(
        dm_rename_tbl(
          dm_for_filter(),
          tf_1...1 = tf_1,
          tf_2...2 = tf_2,
          tf_3...3 = tf_3,
          tf_4...4 = tf_4,
          tf_5...5 = tf_5,
          tf_6...6 = tf_6
        )
      ),
      dm_get_def(dm_for_flatten()),
      dm_get_def(dm_rename_tbl(
        dm_for_filter(),
        tf_1...12 = tf_1,
        tf_2...13 = tf_2,
        tf_3...14 = tf_3,
        tf_4...15 = tf_4,
        tf_5...16 = tf_5,
        tf_6...17 = tf_6
      ))
    ) %>%
      new_dm3()
  )

  expect_silent(
    dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique", quiet = TRUE)
  )
})

test_that("test error output for src mismatches", {
  local_options(lifecycle_verbosity = "warning")

  skip_if_not_installed("dbplyr")

  expect_snapshot({
    writeLines(conditionMessage(expect_error(
      dm_bind(dm_for_flatten(), dm_for_filter_duckdb())
    )))
  })
})

test_that("output", {
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot({
    dm_bind()
    dm_bind(empty_dm())
    dm_bind(dm_for_filter()) %>% collect()
    dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique", quiet = TRUE) %>% collect()
    writeLines(conditionMessage(expect_error(
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    )))
  })

  expect_snapshot({
    dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique") %>% collect()
  })
})

test_that("output for compound keys", {
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot({
    dm_bind(dm_for_filter(), dm_for_flatten()) %>% dm_paste(options = c("select", "keys"))
    dm_bind(dm_for_flatten(), dm_for_filter()) %>% dm_paste(options = c("select", "keys"))
  })

  expect_snapshot({
    dm_bind(dm_for_flatten(), dm_for_flatten(), repair = "unique") %>% dm_paste(options = c("select", "keys"))
  })
})
