# errors: duplicate table names, src mismatches

    Code
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Warning:
      `dm_bind()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error in `pmap()`:
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_21_2023_06_21_19_20_00_265756_19417.a

# test error output for src mismatches

    Code
      writeLines(conditionMessage(expect_error(dm_bind(dm_for_flatten(),
      dm_for_filter_duckdb()))))
    Condition
      Warning:
      `dm_bind()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
      Warning in `dm_for_filter_duckdb()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_duckdb()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
    Output
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_24_2023_06_21_19_20_12_459274_19417.a

# output for compound keys

    Code
      dm_bind(dm_for_flatten(), dm_for_flatten(), repair = "unique") %>% dm_paste(
        options = c("select", "keys"))
    Condition
      Warning:
      `dm_bind()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
    Message
      New names:
      * `fact` -> `fact...1`
      * `dim_1` -> `dim_1...2`
      * `dim_2` -> `dim_2...3`
      * `dim_3` -> `dim_3...4`
      * `dim_4` -> `dim_4...5`
      * `fact` -> `fact...6`
      * `dim_1` -> `dim_1...7`
      * `dim_2` -> `dim_2...8`
      * `dim_3` -> `dim_3...9`
      * `dim_4` -> `dim_4...10`
      dm::dm(
        fact...1,
        dim_1...2,
        dim_2...3,
        dim_3...4,
        dim_4...5,
        fact...6,
        dim_1...7,
        dim_2...8,
        dim_3...9,
        dim_4...10,
      ) %>%
        dm::dm_select(fact...1, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1...2, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2...3, dim_2_pk, something) %>%
        dm::dm_select(dim_3...4, dim_3_pk, something) %>%
        dm::dm_select(dim_4...5, dim_4_pk, something) %>%
        dm::dm_select(fact...6, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1...7, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2...8, dim_2_pk, something) %>%
        dm::dm_select(dim_3...9, dim_3_pk, something) %>%
        dm::dm_select(dim_4...10, dim_4_pk, something) %>%
        dm::dm_add_pk(dim_1...2, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2...3, dim_2_pk) %>%
        dm::dm_add_pk(dim_3...4, dim_3_pk) %>%
        dm::dm_add_pk(dim_4...5, dim_4_pk) %>%
        dm::dm_add_pk(dim_1...7, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2...8, dim_2_pk) %>%
        dm::dm_add_pk(dim_3...9, dim_3_pk) %>%
        dm::dm_add_pk(dim_4...10, dim_4_pk) %>%
        dm::dm_add_fk(fact...1, c(dim_1_key_1, dim_1_key_2), dim_1...2) %>%
        dm::dm_add_fk(fact...1, dim_2_key, dim_2...3) %>%
        dm::dm_add_fk(fact...1, dim_3_key, dim_3...4) %>%
        dm::dm_add_fk(fact...1, dim_4_key, dim_4...5) %>%
        dm::dm_add_fk(fact...6, c(dim_1_key_1, dim_1_key_2), dim_1...7) %>%
        dm::dm_add_fk(fact...6, dim_2_key, dim_2...8) %>%
        dm::dm_add_fk(fact...6, dim_3_key, dim_3...9) %>%
        dm::dm_add_fk(fact...6, dim_4_key, dim_4...10)

