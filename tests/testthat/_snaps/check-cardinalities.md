# check_cardinality_...() functions are checking the cardinality correctly?

    Code
      expect_dm_error(check_cardinality_0_n(parent_table = data_card_1(), pk_column = a,
      child_table = data_card_2(), fk_column = a), class = "not_subset_of")
    Output
      # A tibble: 1 x 2
            a b    
        <dbl> <chr>
      1     6 e    
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

