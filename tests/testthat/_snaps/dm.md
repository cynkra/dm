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
      ! A `list` is not a valid input for this argument. Please enter individual tables or `dm` objects instead.

---

    Code
      dm(a = tibble(), dm_zoom_to(dm_for_filter(), tf_1))
    Condition
      Error in `dm()`:
      ! All dm objects passed to `dm()` must be unzoomed.
      i Argument 2 is a zoomed dm.

---

    object 'weather' not found

---

    A `list` is not a valid input for this argument. Please enter individual tables or `dm` objects instead.

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
      Error in `dm()`:
      ! Names must be unique.
      x These names are duplicated:
        * "tf_1" at locations 1 and 12.
        * "tf_2" at locations 2 and 13.
        * "tf_3" at locations 3 and 14.
        * "tf_4" at locations 4 and 15.
        * "tf_5" at locations 5 and 16.
        * ...

# test error output for src mismatches

    Code
      writeLines(conditionMessage(expect_error(dm(dm_for_flatten(),
      dm_for_filter_duckdb()))))
    Output
      All `dm` objects need to share the same `src`.

# output for dm() with dm

    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Error in `dm()`:
      ! Names must be unique.
      x These names are duplicated:
        * "tf_1" at locations 1 and 12.
        * "tf_2" at locations 2 and 13.
        * "tf_3" at locations 3 and 14.
        * "tf_4" at locations 4 and 15.
        * "tf_5" at locations 5 and 16.
        * ...

---

    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter(), .name_repair = "unique") %>%
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

# output dm() for dm for compound keys

    Code
      dm(dm_for_filter(), dm_for_flatten()) %>% dm_paste(options = c("select", "keys"))
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
      dm(dm_for_flatten(), dm_for_filter()) %>% dm_paste(options = c("select", "keys"))
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

---

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

