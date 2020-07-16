test_that("dm_bind() works?", {
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

test_that("by default error if duplicate table names", {
  expect_dm_error(dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter()), "need_unique_names")
})

test_that("auto-renaming works", {
  expect_equivalent_dm(
    expect_message(
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique"),
      "New names"
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
          tf_6...6 = tf_6)),
      dm_get_def(dm_for_flatten()),
      dm_get_def(dm_rename_tbl(
        dm_for_filter(),
        tf_1...12 = tf_1,
        tf_2...13 = tf_2,
        tf_3...14 = tf_3,
        tf_4...15 = tf_4,
        tf_5...16 = tf_5,
        tf_6...17 = tf_6))
      ) %>%
      new_dm3()
  )

  expect_silent(
    dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique", quiet = TRUE)
  )
})
