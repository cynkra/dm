# dm_add_fk() works as intended?

    Code
      dm_test_obj() %>% dm_add_pk(dm_table_4, c) %>% dm_add_fk(dm_table_1, a,
        dm_table_4) %>% get_all_keys()
    Output
      $pks
      # A tibble: 1 x 3
        table      pk_col autoincrement
        <chr>      <keys> <lgl>        
      1 dm_table_4 c      FALSE        
      
      $fks
      # A tibble: 1 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 dm_table_1  a             dm_table_4   c               no_action
      

# dm_rm_fk() works with partial matching

    Code
      dm_for_filter() %>% dm_rm_fk(tf_5) %>% get_all_keys()
    Message
      Removing foreign keys: %>%
        dm_rm_fk(tf_5, l, tf_4) %>%
        dm_rm_fk(tf_5, m, tf_6, n))
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(columns = l) %>% get_all_keys()
    Message
      Removing foreign keys: %>%
        dm_rm_fk(tf_5, l, tf_4)
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 4 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(columns = c(e, e1)) %>% get_all_keys()
    Message
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3)
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 4 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_4        j, j1         tf_3         f, f1           no_action
      3 tf_5        l             tf_4         h               cascade  
      4 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(ref_table = tf_3) %>% get_all_keys()
    Message
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3)
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_5        l             tf_4         h               cascade  
      3 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(ref_columns = c(f, f1)) %>% get_all_keys()
    Message
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3)
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_5        l             tf_4         h               cascade  
      3 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk() %>% get_all_keys()
    Message
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, d, tf_1) %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3) %>%
        dm_rm_fk(tf_5, l, tf_4) %>%
        dm_rm_fk(tf_5, m, tf_6, n))
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 0 x 5
      # ... with 5 variables: child_table <chr>, child_fk_cols <keys>,
      #   parent_table <chr>, parent_key_cols <keys>, on_delete <chr>
      

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

