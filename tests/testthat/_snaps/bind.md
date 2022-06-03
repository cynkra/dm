# test error output for src mismatches

    Code
      writeLines(conditionMessage(expect_error(dm_bind(dm_for_flatten(),
      dm_for_filter_sqlite()))))
    Output
      All `dm` objects need to share the same `src`.

# output

    Code
      dm_bind()
    Output
      dm()
    Code
      dm_bind(empty_dm())
    Output
      dm()
    Code
      dm_bind(dm_for_filter()) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
    Code
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique",
      quiet = TRUE) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1...1`, `tf_2...2`, `tf_3...3`, `tf_4...4`, `tf_5...5`, ... (17 total)
      Columns: 56
      Primary keys: 16
      Foreign keys: 14
    Code
      writeLines(conditionMessage(expect_error(dm_bind(dm_for_filter(),
      dm_for_flatten(), dm_for_filter()))))
    Output
      Each new table needs to have a unique name. Duplicate new name(s): `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`.

# output dev vctrs

    Code
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique") %>%
        collect()
    Message
      New names:
      * `tf_1` -> `tf_1...1`
      * `tf_2` -> `tf_2...2`
      * `tf_3` -> `tf_3...3`
      * `tf_4` -> `tf_4...4`
      * `tf_5` -> `tf_5...5`
      * `tf_6` -> `tf_6...6`
      * `tf_1` -> `tf_1...12`
      * `tf_2` -> `tf_2...13`
      * `tf_3` -> `tf_3...14`
      * `tf_4` -> `tf_4...15`
      * `tf_5` -> `tf_5...16`
      * `tf_6` -> `tf_6...17`
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1...1`, `tf_2...2`, `tf_3...3`, `tf_4...4`, `tf_5...5`, ... (17 total)
      Columns: 56
      Primary keys: 16
      Foreign keys: 14

# output for compound keys

    Code
      dm_bind(dm_for_filter(), dm_for_flatten()) %>% dm_paste(options = c("select",
        "keys"))
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
      ) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e, e1) %>%
        dm::dm_select(tf_3, f, f1, g) %>%
        dm::dm_select(tf_4, h, i, j, j1) %>%
        dm::dm_select(tf_5, ww, k, l, m) %>%
        dm::dm_select(tf_6, zz, n, o) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)
    Code
      dm_bind(dm_for_flatten(), dm_for_filter()) %>% dm_paste(options = c("select",
        "keys"))
    Message
      dm::dm(
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e, e1) %>%
        dm::dm_select(tf_3, f, f1, g) %>%
        dm::dm_select(tf_4, h, i, j, j1) %>%
        dm::dm_select(tf_5, ww, k, l, m) %>%
        dm::dm_select(tf_6, zz, n, o) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)

# output for compound keys dev vctrs

    Code
      dm_bind(dm_for_flatten(), dm_for_flatten(), repair = "unique") %>% dm_paste(
        options = c("select", "keys"))
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

