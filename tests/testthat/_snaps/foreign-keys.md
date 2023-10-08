# can add foreign key with cascade

    Code
      dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_add_fk(a, x, b, x, on_delete = "cascade") %>%
        dm_get_all_fks()
    Output
      # A tibble: 1 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 a           x             b            x               cascade  

# bogus arguments are rejected

    Code
      dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_add_fk(a, x, b, x, on_delete = "bogus")
    Condition
      Error in `dm_add_fk()`:
      ! `on_delete` must be one of "no_action" or "cascade", not "bogus".
    Code
      dm(a = tibble(x = 1), b = tibble(x = 1)) %>% dm_add_fk(a, x, b, x, on_delete = letters)
    Condition
      Error in `dm_add_fk()`:
      ! `on_delete` must be one of "no_action" or "cascade", not "a".

# dm_get_all_fks() with parent_table arg fails nicely

    You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NUMERIC) AS `lat`,
      CAST(`lon` AS NUMERIC) AS `lon`,
      CAST(`alt` AS NUMERIC) A' at line 5 [1064]

