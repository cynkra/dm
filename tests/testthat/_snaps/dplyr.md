# basic test: 'join()'-methods for `zoomed.dm` work (2)

    Code
      # keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'
      dm_zoomed() %>% left_join(tf_3, select = c(d = g, f, f1)) %>% dm_update_zoomed() %>%
        get_all_keys()
    Message
      Renaming ambiguous columns: %>%
        dm_rename(tf_2, d.tf_2 = d) %>%
        dm_rename(tf_3, d.tf_3 = d)
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      TRUE         
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d.tf_2        tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      # keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'
      dm_zoomed() %>% semi_join(tf_3, select = c(d = g, f, f1)) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      TRUE         
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      

