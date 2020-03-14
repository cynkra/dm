test_that("check_cardinality_...() functions are checking the cardinality correctly?", {
  card_0_n_d1_d2_names <- find_testthat_root_file(paste0("out/card-0-n-d1-d2-", src_names, ".txt"))
  card_0_1_d1_d2_names <- find_testthat_root_file(paste0("out/card-0-1-d1-d2-", src_names, ".txt"))

  #  expecting silent: ------------------------------------------------------

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_cardinality_0_n(parent_table = .x, pk_column = a, child_table = .y, fk_column = c)
    )
  )

  expect_silent(check_cardinality_1_n(d1, a, d3, c))

  expect_silent(check_cardinality_1_1(d1, a, d3, c))

  expect_silent(check_set_equality(d1, a, d3, c))

  expect_silent(check_cardinality_0_n(d5, a, d4, c))

  expect_silent(check_cardinality_0_1(d5, a, d6, c))

  walk2(
    d8_src,
    d2_src,
    ~ expect_identical(
      examine_cardinality(.x, c, .y, a),
      "injective mapping ( child: 0 or 1 -> parent: 1)"
    )
  )

  expect_identical(
    examine_cardinality(d5, a, d4, c),
    "surjective mapping (child: 1 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(d8, c, d4, c),
    "generic mapping (child: 0 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(d1, a, d3, c),
    "bijective mapping (child: 1 -> parent: 1)"
  )

  # expect specific errors and sometimes specific output due to errors ---------------

  pmap(
    list(
      d1_src,
      d2_src,
      card_0_n_d1_d2_names
    ),
    ~ expect_known_output(
      expect_dm_error(
        check_cardinality_0_n(
          parent_table = ..1,
          pk_column = a,
          child_table = ..2,
          fk_column = a
        ),
        class = "not_subset_of"
      ),
      ..3
    )
  )

  expect_dm_error(
    check_cardinality_1_1(d5, a, d4, c),
    class = "not_bijective"
  )

  expect_dm_error(
    check_cardinality_1_1(d4, c, d5, a),
    class = "not_unique_key"
  )

  expect_dm_error(
    check_cardinality_1_1(d4, c, d1, a),
    class = "not_unique_key"
  )

  expect_dm_error(
    check_cardinality_0_1(d1, a, d4, c),
    class = "not_injective"
  )

  expect_dm_error(
    check_cardinality_0_n(d4, c, d1, a),
    class = "not_unique_key"
  )

  expect_dm_error(
    check_cardinality_1_1(d4, c, d1, a),
    class = "not_unique_key"
  )

  expect_dm_error(
    check_cardinality_1_1(d1, a, d4, c),
    class = "not_bijective"
  )
})
