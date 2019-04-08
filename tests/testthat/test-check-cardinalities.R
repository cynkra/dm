context("test-check-cardinalities")

test_that("check_cardinality_...() functions are checking the cardinality correctly?", {
  # expecting silent:

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_cardinality_0_n(parent_table = .x, primary_key_column = a, child_table = .y, foreign_key_column = c)
      )
    )

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_cardinality_1_n(.x, a, .y, c)
      )
    )

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_cardinality_1_1(.x, a, .y, c)
    )
  )

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_set_equality(.x, a, .y, c)
    )
  )

  expect_silent(
    map2(
      .x = d5_src,
      .y = d4_src,
      ~ check_cardinality_0_n(.x, a, .y, c)
    )
  )

  expect_silent(
    map2(
      .x = d5_src,
      .y = d6_src,
      ~ check_cardinality_0_1(.x, a, .y, c)
    )
  )

  # FIXME: this should work, but there is still an issue with DB compatibility (both in Postgres and in SQLite)
  # map2(
  #   .x = d1_src,
  #   .y = d2_src,
  #   ~ expect_known_output(
  #     expect_error(
  #       check_cardinality_0_n(
  #         parent_table = .x,
  #         primary_key_column = a,
  #         child_table = .y,
  #         foreign_key_column = a
  #       )
  #     ),
  #     "out/card-0-n-d1-d2.txt"
  #   )
  # )

  expect_known_output(
    expect_error(
      check_cardinality_0_n(
        parent_table = d1,
        primary_key_column = a,
        child_table = d2,
        foreign_key_column = a
      )
    ),
    "out/card-0-n-d1-d2.txt"
  )


  expect_known_output(
    expect_error(
      check_cardinality_0_1(d1, a, d2, a)
    ),
    "out/card-0-1-d1-d2.txt"
  )

  expect_error(check_cardinality_1_1(d5, a, d4, c))
  expect_error(check_cardinality_0_n(d4, c, d5, a))
  expect_error(check_cardinality_0_1(d4, c, d1, a))
  expect_error(check_cardinality_0_1(d1, a, d4, c))
  expect_error(check_cardinality_1_1(d4, c, d1, a))
  expect_error(check_cardinality_1_1(d1, a, d4, c))
})
