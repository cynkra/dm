# dm_rename() works for replacing pk

    Code
      dm_for_filter() %>% dm_rename(tf_3, new_f = f) %>% dm_get_all_pks_impl()
    Output
      # A tibble: 6 x 2
        table pk_cols  
        <chr> <keys>   
      1 tf_1  a        
      2 tf_2  c        
      3 tf_3  new_f, f1
      4 tf_4  h        
      5 tf_5  k        
      6 tf_6  o        

# dm_rename() works for replacing fks

    Code
      dm_for_filter() %>% dm_rename(tf_2, new_d = d, new_e = e) %>%
        dm_get_all_fks_impl()
    Output
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        new_d         tf_1         a               no_action
      2 tf_2        new_e, e1     tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action

# dm_select() works for replacing pk

    Code
      dm_for_filter() %>% dm_select(tf_3, new_f = f) %>% dm_get_all_pks_impl()
    Output
      # A tibble: 5 x 2
        table pk_cols
        <chr> <keys> 
      1 tf_1  a      
      2 tf_2  c      
      3 tf_4  h      
      4 tf_5  k      
      5 tf_6  o      

# dm_select() works for replacing fks, and removes missing ones

    Code
      dm_for_filter() %>% dm_select(tf_2, new_d = d) %>% dm_get_all_fks_impl()
    Output
      # A tibble: 4 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        new_d         tf_1         a               no_action
      2 tf_4        j, j1         tf_3         f, f1           no_action
      3 tf_5        l             tf_4         h               cascade  
      4 tf_5        m             tf_6         n               no_action

