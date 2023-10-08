# output

    Code
      dm(x = tibble(a = c(1, 1))) %>% dm_add_pk(x, a, check = TRUE)
    Condition
      Error in `abort_not_unique_key()`:
      ! (`a`) not a unique key of `x`.

# dm_get_all_pks() with table arg fails nicely

    You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'INTEGER) AS `year`,
      CAST(`month` AS INTEGER) AS `month`,
      CAST(`day` AS INTEG' at line 3 [1064]

# autoincrement fails with compound keys

    Code
      dm(x) %>% dm_add_pk(x, columns = c(x_id, z), autoincrement = TRUE)
    Condition
      Error in `dm_add_pk()`:
      ! Composite primary keys cannot be autoincremented.
      * Provide only a single column name to `columns`.

# set autoincrement PK

    Code
      dm(x, y = x) %>% dm_add_pk(x, columns = c(x_id), autoincrement = TRUE) %>%
        dm_add_pk(y, columns = c(x_id, z)) %>% dm_get_all_pks()
    Output
      # A tibble: 2 x 3
        table pk_col  autoincrement
        <chr> <keys>  <lgl>        
      1 x     x_id    TRUE         
      2 y     x_id, z FALSE        

