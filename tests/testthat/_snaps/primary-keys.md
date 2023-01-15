# dm_add_pk() works as intended?

    Code
      dm(x = tibble(x = integer())) %>% dm_add_pk(x)
    Condition
      Error in `dm_add_pk()`:
      ! `columns` is absent but must be supplied.

# dm_rm_pk() supports partial filters

    Code
      dm_for_filter() %>% dm_rm_pk(tf_4) %>% get_all_keys()
    Output
      $pks
      # A tibble: 5 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_5  k      FALSE        
      5 tf_6  o      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_pk(tf_3) %>% get_all_keys()
    Output
      $pks
      # A tibble: 5 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_4  h      FALSE        
      4 tf_5  k      FALSE        
      5 tf_6  o      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_pk(tf_6) %>% get_all_keys()
    Output
      $pks
      # A tibble: 5 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_pk(tf_4, rm_referencing_fks = TRUE) %>% get_all_keys()
    Condition
      Warning:
      The `rm_referencing_fks` argument of `dm_rm_pk()` is deprecated as of dm 0.2.1.
      i When removing a primary key, potential associated foreign keys will be pointing at an implicit unique key.
    Output
      $pks
      # A tibble: 5 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_5  k      FALSE        
      5 tf_6  o      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_pk(columns = c) %>% get_all_keys()
    Message
      Removing primary keys: %>%
        dm_rm_pk(tf_2)
    Output
      $pks
      # A tibble: 5 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_3  f, f1  FALSE        
      3 tf_4  h      FALSE        
      4 tf_5  k      FALSE        
      5 tf_6  o      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_pk(columns = c(f, f1)) %>% get_all_keys()
    Message
      Removing primary keys: %>%
        dm_rm_pk(tf_3)
    Output
      $pks
      # A tibble: 5 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_4  h      FALSE        
      4 tf_5  k      FALSE        
      5 tf_6  o      FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_pk(fail_fk = FALSE) %>% get_all_keys()
    Condition
      Warning:
      The `fail_fk` argument of `dm_rm_pk()` is deprecated as of dm 1.0.4.
      i When removing a primary key, potential associated foreign keys will be pointing at an implicit unique key.
    Message
      Removing primary keys: %>%
        dm_rm_pk(tf_1) %>%
        dm_rm_pk(tf_2) %>%
        dm_rm_pk(tf_3) %>%
        dm_rm_pk(tf_4) %>%
        dm_rm_pk(tf_5) %>%
        dm_rm_pk(tf_6)
    Output
      $pks
      # A tibble: 0 x 3
      # * 3 variables: table <chr>, pk_col <keys>, autoincrement <lgl>
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      

# dm_enum_pk_candidates() works properly?

    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_1)
    Output
      # A tibble: 2 x 3
        columns candidate why  
        <keys>  <lgl>     <chr>
      1 a       TRUE      ""   
      2 b       TRUE      ""   
    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_2)
    Output
      # A tibble: 1 x 3
        columns candidate why                        
        <keys>  <lgl>     <chr>                      
      1 c       FALSE     has duplicate values: 5 (2)
    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_5)
    Output
      # A tibble: 1 x 3
        columns candidate why                 
        <keys>  <lgl>     <chr>               
      1 c       FALSE     has 1 missing values
    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_6)
    Output
      # A tibble: 1 x 3
        columns candidate why                                              
        <keys>  <lgl>     <chr>                                            
      1 c       FALSE     has 1 missing values, and duplicate values: 3 (2)

# output

    Code
      dm(x = tibble(a = c(1, 1))) %>% dm_add_pk(x, a, check = TRUE)
    Condition
      Error in `abort_not_unique_key()`:
      ! (`a`) not a unique key of `x`.

# dm_get_all_pks() with table arg

    Code
      nyc_comp() %>% dm_get_all_pks("weather")
    Output
      # A tibble: 1 x 3
        table   pk_col            autoincrement
        <chr>   <keys>            <lgl>        
      1 weather origin, time_hour FALSE        
    Code
      nyc_comp() %>% dm_get_all_pks(c("airlines", "weather"))
    Output
      # A tibble: 2 x 3
        table    pk_col            autoincrement
        <chr>    <keys>            <lgl>        
      1 airlines carrier           FALSE        
      2 weather  origin, time_hour FALSE        

# dm_get_all_pks() with table arg fails nicely

    Table `timetable`, `tabletime` not in `dm` object. Available table names: `airlines`, `airports`, `flights`, `planes`, `weather`.

# dm_get_all_pks() with compound keys

    Code
      nyc_comp()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp() %>% dm_get_all_pks()
    Output
      # A tibble: 4 x 3
        table    pk_col            autoincrement
        <chr>    <keys>            <lgl>        
      1 airlines carrier           FALSE        
      2 airports faa               FALSE        
      3 planes   tailnum           FALSE        
      4 weather  origin, time_hour FALSE        

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

