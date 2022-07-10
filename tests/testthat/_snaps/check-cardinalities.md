# check_cardinality_...() functions work without `x_select` and `y_select`

    Code
      examine_cardinality(data_card_1(), data_card_11())
    Output
      [1] "injective mapping (child: 0 or 1 -> parent: 1)"
    Code
      examine_cardinality(data_card_1(), data_card_12())
    Output
      [1] "surjective mapping (child: 1 to n -> parent: 1)"
    Code
      examine_cardinality(data_card_1(), data_card_1())
    Output
      [1] "bijective mapping (child: 1 -> parent: 1)"
    Code
      examine_cardinality(data_card_1(), data_card_11())
    Output
      [1] "injective mapping (child: 0 or 1 -> parent: 1)"

# check_cardinality_...() functions are checking the cardinality correctly?

    Code
      expect_dm_error(check_cardinality_0_n(parent_table = data_card_1(), pk_column = a,
      child_table = data_card_2(), fk_column = a), class = "not_subset_of")
    Output
      # A tibble: 1 x 1
            a
        <dbl>
      1     6
    Code
      expect_dm_error(check_cardinality_1_1(data_card_5(), a, data_card_4(), c),
      class = "not_bijective")
      expect_dm_error(check_cardinality_1_1(data_card_4(), c, data_card_5(), a),
      class = "not_unique_key")
      expect_dm_error(check_cardinality_1_1(data_card_4(), c, data_card_1(), a),
      class = "not_unique_key")
      expect_dm_error(check_cardinality_0_1(data_card_1(), a, data_card_4(), c),
      class = "not_injective")
      expect_dm_error(check_cardinality_0_n(data_card_4(), c, data_card_1(), a),
      class = "not_unique_key")
      expect_dm_error(check_cardinality_1_1(data_card_4(), c, data_card_1(), a),
      class = "not_unique_key")
      expect_dm_error(check_cardinality_1_1(data_card_1(), a, data_card_4(), c),
      class = "not_bijective")

# check_cardinality_...() functions are supporting compound keys

    Code
      expect_dm_error(check_cardinality_0_n(parent_table = data_card_1(), pk_column = c(
        a, b), child_table = data_card_2(), fk_column = c(a, b)), class = "not_subset_of")
    Output
      # A tibble: 4 x 2
            a b    
        <dbl> <chr>
      1     3 b    
      2     4 c    
      3     5 d    
      4     6 e    
    Code
      expect_dm_error(check_cardinality_1_1(data_card_1(), c(a, b), data_card_12(), c(
        a, b)), class = "not_bijective")
      expect_dm_error(check_cardinality_1_1(data_card_12(), c(a, b), data_card_1(), c(
        a, b)), class = "not_unique_key")
      expect_dm_error(check_cardinality_0_1(data_card_1(), c(b, a), data_card_12(), c(
        b, a)), class = "not_injective")

