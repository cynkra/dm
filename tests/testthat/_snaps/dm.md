# dm() API

    Code
      dm(a = tibble(), a = tibble(), .name_repair = "unique")
    Message
      New names:
      * `a` -> `a...1`
      * `a` -> `a...2`
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `a...1`, `a...2`
      Columns: 0
      Primary keys: 0
      Foreign keys: 0
    Code
      dm(a = tibble(), a = tibble(), .name_repair = "unique", .quiet = TRUE)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `a...1`, `a...2`
      Columns: 0
      Primary keys: 0
      Foreign keys: 0

---

    Code
      dm(a = tibble(), a = tibble())
    Condition
      Error in `dm()`:
      ! Names must be unique.
      x These names are duplicated:
        * "a" at locations 1 and 2.

---

    Code
      dm(a = dm())
    Condition
      Error in `dm()`:
      ! All dm objects passed to `dm()` must be unnamed.
      i Argument 1 has name `a`.

---

    Code
      dm(a = tibble(), dm_zoom_to(dm_for_filter(), tf_1))
    Condition
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error in `map()`:
      i In index: 2.
      Caused by error in `pmap()`:
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_41_2023_06_21_19_21_51_485931_19417.a

# dm() for adding tables with compound keys

    Code
      dm(dm_for_flatten(), res_flat = result_from_flatten()) %>% dm_paste(options = c(
        "select", "keys"))
    Message
      dm::dm(
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
        res_flat,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_select(res_flat, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, fact.something, dim_1.something, dim_2.something, dim_3.something, dim_4.something) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)

# errors: duplicate table names, src mismatches

    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error in `map()`:
      i In index: 1.
      Caused by error in `pmap()`:
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_44_2023_06_21_19_21_58_393778_19417.a

# test error output for src mismatches

    Code
      writeLines(conditionMessage(expect_error(dm(dm_for_flatten(),
      dm_for_filter_duckdb()))))
    Condition
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
      i In index: 2.
      Caused by error in `pmap()`:
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_47_2023_06_21_19_22_03_818985_19417.a

# output for dm() with dm

    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error in `map()`:
      i In index: 1.
      Caused by error in `pmap()`:
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_50_2023_06_21_19_22_09_223211_19417.a

# output dm() for dm for compound keys

    Code
      dm(dm_for_flatten(), dm_for_flatten(), .name_repair = "unique") %>% dm_paste(
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

# output

    Code
      print(dm())
    Output
      dm()
    Code
      nyc_flights_dm <- dm_nycflights_small()
      collect(nyc_flights_dm)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 3
    Code
      nyc_flights_dm %>% format()
    Output
      dm: 5 tables, 53 columns, 3 primary keys, 3 foreign keys
    Code
      nyc_flights_dm %>% dm_filter(flights = (origin == "EWR")) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 3

