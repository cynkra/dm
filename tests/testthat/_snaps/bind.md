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

