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
      Columns: 15
      Primary keys: 6
      Foreign keys: 5
    Code
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique") %>%
        collect()
    Message <simpleMessage>
      New names:
      * tf_1 -> tf_1...1
      * tf_2 -> tf_2...2
      * tf_3 -> tf_3...3
      * tf_4 -> tf_4...4
      * tf_5 -> tf_5...5
      * ...
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1...1`, `tf_2...2`, `tf_3...3`, `tf_4...4`, `tf_5...5`, ... (17 total)
      Columns: 44
      Primary keys: 16
      Foreign keys: 14
    Code
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter(), repair = "unique",
      quiet = TRUE) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1...1`, `tf_2...2`, `tf_3...3`, `tf_4...4`, `tf_5...5`, ... (17 total)
      Columns: 44
      Primary keys: 16
      Foreign keys: 14
    Code
      writeLines(conditionMessage(expect_error(dm_bind(dm_for_filter(),
      dm_for_flatten(), dm_for_filter()))))
    Output
      Each new table needs to have a unique name. Duplicate new name(s): `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`.

# output for compound keys

    Code
      dm_bind(dm_for_flatten(), dm_for_flatten(), repair = "unique") %>% dm_paste(
        options = c("select", "keys"))
    Message <simpleMessage>
      New names:
      * fact -> fact...1
      * dim_1 -> dim_1...2
      * dim_2 -> dim_2...3
      * dim_3 -> dim_3...4
      * dim_4 -> dim_4...5
      * ...
    Message <cliMessage>
      dm::dm(fact...1, dim_1...2, dim_2...3, dim_3...4, dim_4...5, fact...6, dim_1...7, dim_2...8, dim_3...9, dim_4...10) %>%
        dm::dm_select(fact...1, fact, dim_1_key, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1...2, dim_1_pk, something) %>%
        dm::dm_select(dim_2...3, dim_2_pk, something) %>%
        dm::dm_select(dim_3...4, dim_3_pk, something) %>%
        dm::dm_select(dim_4...5, dim_4_pk, something) %>%
        dm::dm_select(fact...6, fact, dim_1_key, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1...7, dim_1_pk, something) %>%
        dm::dm_select(dim_2...8, dim_2_pk, something) %>%
        dm::dm_select(dim_3...9, dim_3_pk, something) %>%
        dm::dm_select(dim_4...10, dim_4_pk, something) %>%
        dm::dm_add_pk(dim_1...2, dim_1_pk) %>%
        dm::dm_add_pk(dim_2...3, dim_2_pk) %>%
        dm::dm_add_pk(dim_3...4, dim_3_pk) %>%
        dm::dm_add_pk(dim_4...5, dim_4_pk) %>%
        dm::dm_add_pk(dim_1...7, dim_1_pk) %>%
        dm::dm_add_pk(dim_2...8, dim_2_pk) %>%
        dm::dm_add_pk(dim_3...9, dim_3_pk) %>%
        dm::dm_add_pk(dim_4...10, dim_4_pk) %>%
        dm::dm_add_fk(fact...1, dim_1_key, dim_1...2) %>%
        dm::dm_add_fk(fact...1, dim_2_key, dim_2...3) %>%
        dm::dm_add_fk(fact...1, dim_3_key, dim_3...4) %>%
        dm::dm_add_fk(fact...1, dim_4_key, dim_4...5) %>%
        dm::dm_add_fk(fact...6, dim_1_key, dim_1...7) %>%
        dm::dm_add_fk(fact...6, dim_2_key, dim_2...8) %>%
        dm::dm_add_fk(fact...6, dim_3_key, dim_3...9) %>%
        dm::dm_add_fk(fact...6, dim_4_key, dim_4...10)
    Code
      dm_bind(dm_for_filter(), dm_for_flatten()) %>% dm_paste(options = c("select",
        "keys"))
    Message <cliMessage>
      dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6, fact, dim_1, dim_2, dim_3, dim_4) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e) %>%
        dm::dm_select(tf_3, f, g) %>%
        dm::dm_select(tf_4, h, i, j) %>%
        dm::dm_select(tf_5, k, l, m) %>%
        dm::dm_select(tf_6, n, o) %>%
        dm::dm_select(fact, fact, dim_1_key, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, f) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, n) %>%
        dm::dm_add_pk(dim_1, dim_1_pk) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(fact, dim_1_key, dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, e, tf_3) %>%
        dm::dm_add_fk(tf_4, j, tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4) %>%
        dm::dm_add_fk(tf_5, m, tf_6)
    Code
      dm_bind(dm_for_flatten(), dm_for_filter()) %>% dm_paste(options = c("select",
        "keys"))
    Message <cliMessage>
      dm::dm(fact, dim_1, dim_2, dim_3, dim_4, tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%
        dm::dm_select(fact, fact, dim_1_key, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e) %>%
        dm::dm_select(tf_3, f, g) %>%
        dm::dm_select(tf_4, h, i, j) %>%
        dm::dm_select(tf_5, k, l, m) %>%
        dm::dm_select(tf_6, n, o) %>%
        dm::dm_add_pk(dim_1, dim_1_pk) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, f) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, n) %>%
        dm::dm_add_fk(fact, dim_1_key, dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, e, tf_3) %>%
        dm::dm_add_fk(tf_4, j, tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4) %>%
        dm::dm_add_fk(tf_5, m, tf_6)

