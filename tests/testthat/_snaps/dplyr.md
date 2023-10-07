# key tracking works

    Code
      # rename()
      zoomed_grouped_out_dm %>% rename(c_new = c) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col    autoincrement
        <chr> <dm_keys> <lgl>        
      1 tf_1  a         TRUE         
      2 tf_2  c_new     FALSE        
      3 tf_3  f, f1     FALSE        
      4 tf_4  h         FALSE        
      5 tf_5  k         FALSE        
      6 tf_6  o         FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      zoomed_grouped_out_dm %>% rename(e_new = e) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col    autoincrement
        <chr> <dm_keys> <lgl>        
      1 tf_1  a         TRUE         
      2 tf_2  c         FALSE        
      3 tf_3  f, f1     FALSE        
      4 tf_4  h         FALSE        
      5 tf_5  k         FALSE        
      6 tf_6  o         FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e_new, e1     tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      zoomed_grouped_in_dm %>% rename(f_new = f) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col    autoincrement
        <chr> <dm_keys> <lgl>        
      1 tf_1  a         TRUE         
      2 tf_2  c         FALSE        
      3 tf_3  f_new, f1 FALSE        
      4 tf_4  h         FALSE        
      5 tf_5  k         FALSE        
      6 tf_6  o         FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f_new, f1       no_action
      3 tf_4        j, j1         tf_3         f_new, f1       no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      # summarize()
      zoomed_grouped_out_dm %>% summarize(d_mean = mean(d)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 3
        table   pk_col    autoincrement
        <chr>   <dm_keys> <lgl>        
      1 tf_1    a         TRUE         
      2 tf_2    c         FALSE        
      3 tf_3    f, f1     FALSE        
      4 tf_4    h         FALSE        
      5 tf_5    k         FALSE        
      6 tf_6    o         FALSE        
      7 new_tbl c         FALSE        
      
      $fks
      # A tibble: 6 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 new_tbl     e, e1         tf_3         f, f1           no_action
      5 tf_5        l             tf_4         h               cascade  
      6 tf_5        m             tf_6         n               no_action
      
    Code
      zoomed_grouped_in_dm %>% summarize(g_list = list(g)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col    autoincrement
        <chr> <dm_keys> <lgl>        
      1 tf_1  a         TRUE         
      2 tf_2  c         FALSE        
      3 tf_3  f, f1     FALSE        
      4 tf_4  h         FALSE        
      5 tf_5  k         FALSE        
      6 tf_6  o         FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      

# key tracking works (2)

    Code
      # transmute()
      zoomed_grouped_out_dm %>% transmute(d_mean = mean(d)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 3
        table   pk_col    autoincrement
        <chr>   <dm_keys> <lgl>        
      1 tf_1    a         TRUE         
      2 tf_2    c         FALSE        
      3 tf_3    f, f1     FALSE        
      4 tf_4    h         FALSE        
      5 tf_5    k         FALSE        
      6 tf_6    o         FALSE        
      7 new_tbl c         FALSE        
      
      $fks
      # A tibble: 6 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 new_tbl     e, e1         tf_3         f, f1           no_action
      5 tf_5        l             tf_4         h               cascade  
      6 tf_5        m             tf_6         n               no_action
      

# key tracking works (3)

    Code
      zoomed_grouped_in_dm %>% transmute(g_list = list(g)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 6 x 3
        table pk_col    autoincrement
        <chr> <dm_keys> <lgl>        
      1 tf_1  a         TRUE         
      2 tf_2  c         FALSE        
      3 tf_3  f, f1     FALSE        
      4 tf_4  h         FALSE        
      5 tf_5  k         FALSE        
      6 tf_6  o         FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      

# key tracking works (4)

    Code
      # mutate()
      zoomed_grouped_out_dm %>% mutate(d_mean = mean(d)) %>% select(-d) %>%
        dm_insert_zoomed("new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 3
        table   pk_col    autoincrement
        <chr>   <dm_keys> <lgl>        
      1 tf_1    a         TRUE         
      2 tf_2    c         FALSE        
      3 tf_3    f, f1     FALSE        
      4 tf_4    h         FALSE        
      5 tf_5    k         FALSE        
      6 tf_6    o         FALSE        
      7 new_tbl c         FALSE        
      
      $fks
      # A tibble: 6 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 new_tbl     e, e1         tf_3         f, f1           no_action
      5 tf_5        l             tf_4         h               cascade  
      6 tf_5        m             tf_6         n               no_action
      
    Code
      zoomed_grouped_in_dm %>% mutate(f = paste0(g, g)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 3
        table   pk_col    autoincrement
        <chr>   <dm_keys> <lgl>        
      1 tf_1    a         TRUE         
      2 tf_2    c         FALSE        
      3 tf_3    f, f1     FALSE        
      4 tf_4    h         FALSE        
      5 tf_5    k         FALSE        
      6 tf_6    o         FALSE        
      7 new_tbl f, f1     FALSE        
      
      $fks
      # A tibble: 7 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      6 tf_2        e, e1         new_tbl      f, f1           no_action
      7 tf_4        j, j1         new_tbl      f, f1           no_action
      
    Code
      zoomed_grouped_in_dm %>% mutate(g_new = list(g)) %>% dm_insert_zoomed("new_tbl") %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 7 x 3
        table   pk_col    autoincrement
        <chr>   <dm_keys> <lgl>        
      1 tf_1    a         TRUE         
      2 tf_2    c         FALSE        
      3 tf_3    f, f1     FALSE        
      4 tf_4    h         FALSE        
      5 tf_5    k         FALSE        
      6 tf_6    o         FALSE        
      7 new_tbl f, f1     FALSE        
      
      $fks
      # A tibble: 7 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      6 tf_2        e, e1         new_tbl      f, f1           no_action
      7 tf_4        j, j1         new_tbl      f, f1           no_action
      

# key tracking works (5)

    Code
      # chain of renames & other transformations
      zoomed_grouped_out_dm %>% summarize(d_mean = mean(d)) %>% ungroup() %>% rename(
        e_new = e) %>% group_by(e_new, e1) %>% transmute(c = paste0(c, "_animal")) %>%
        dm_insert_zoomed("new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 3
        table   pk_col    autoincrement
        <chr>   <dm_keys> <lgl>        
      1 tf_1    a         TRUE         
      2 tf_2    c         FALSE        
      3 tf_3    f, f1     FALSE        
      4 tf_4    h         FALSE        
      5 tf_5    k         FALSE        
      6 tf_6    o         FALSE        
      7 new_tbl c         FALSE        
      
      $fks
      # A tibble: 6 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 new_tbl     e_new, e1     tf_3         f, f1           no_action
      5 tf_5        l             tf_4         h               cascade  
      6 tf_5        m             tf_6         n               no_action
      

# key tracking works (6)

    Code
      zoomed_grouped_in_dm %>% select(g_new = g) %>% get_all_keys("tf_3")
    Output
      $pks
      # A tibble: 1 x 3
        table pk_col    autoincrement
        <chr> <dm_keys> <lgl>        
      1 tf_3  f, f1     FALSE        
      
      $fks
      # A tibble: 2 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <dm_keys>     <chr>        <dm_keys>       <chr>    
      1 tf_2        e, e1         tf_3         f, f1           no_action
      2 tf_4        j, j1         tf_3         f, f1           no_action
      

