test_that("check_cardinality_...() functions are checking the cardinality correctly?", {
  #  expecting silent: ------------------------------------------------------

  expect_silent(check_cardinality_0_n(parent_table = data_card_1(), pk_column = a, child_table = data_card_3(), fk_column = c))

  expect_silent(check_cardinality_1_n(data_card_1(), a, data_card_3(), c))

  expect_silent(check_cardinality_1_1(data_card_1(), a, data_card_3(), c))

  expect_silent(check_set_equality(data_card_1(), a, data_card_3(), c))

  expect_silent(check_cardinality_0_n(data_card_5(), a, data_card_4(), c))

  expect_silent(check_cardinality_0_1(data_card_5(), a, data_card_6(), c))


  # scenarios for examine_cardinality() -------------------------------------

  expect_identical(
    examine_cardinality(data_card_8(), c, data_card_2(), a),
    "injective mapping (child: 0 or 1 -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_5(), a, data_card_4(), c),
    "surjective mapping (child: 1 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_8(), c, data_card_4(), c),
    "generic mapping (child: 0 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_1(), a, data_card_3(), c),
    "bijective mapping (child: 1 -> parent: 1)"
  )

  # expect specific errors and sometimes specific output due to errors ---------------

  expect_snapshot({
    expect_dm_error(
      check_cardinality_0_n(
        parent_table = data_card_1(),
        pk_column = a,
        child_table = data_card_2(),
        fk_column = a
      ),
      class = "not_subset_of"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_5(), a, data_card_4(), c),
      class = "not_bijective"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_4(), c, data_card_5(), a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_4(), c, data_card_1(), a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_0_1(data_card_1(), a, data_card_4(), c),
      class = "not_injective"
    )

    expect_dm_error(
      check_cardinality_0_n(data_card_4(), c, data_card_1(), a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_4(), c, data_card_1(), a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_1(), a, data_card_4(), c),
      class = "not_bijective"
    )
  })
})
