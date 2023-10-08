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
      Caused by error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW(1, 'A'),
          ROW(2, 'B'),
          ROW(3, 'C'),
          ROW(4, 'D'),
          ROW(5, 'E...' at line 11 [1064]

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
      Caused by error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW(1, 'A'),
          ROW(2, 'B'),
          ROW(3, 'C'),
          ROW(4, 'D'),
          ROW(5, 'E...' at line 11 [1064]

# test error output for src mismatches

    Code
      writeLines(conditionMessage(expect_error(dm(dm_for_flatten(),
      dm_for_filter_duckdb()))))
    Condition
      Warning in `dm_for_flatten()`:
      restarting interrupted promise evaluation
    Output
      i In index: 1.
      Caused by error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW('acorn', 14, 'N', 'c', 'X', 7, 1),
          ROW('blubber', 13, 'M', 'd', 'W', ...' at line 25 [1064]

# output for dm() with dm (2)

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
      Caused by error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW(1, 'A'),
          ROW(2, 'B'),
          ROW(3, 'C'),
          ROW(4, 'D'),
          ROW(5, 'E...' at line 11 [1064]

