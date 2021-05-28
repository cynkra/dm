# dm_rm_pk() supports partial filters

    Code
      dm_for_filter() |> dm_rm_pk(tf_4, fail_fk = FALSE) |> get_all_keys()
    Output
      $pks
      # A tibble: 5 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_5  k     
      5 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      dm_for_filter() |> dm_rm_pk(tf_3, fail_fk = FALSE) |> get_all_keys()
    Output
      $pks
      # A tibble: 5 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_4  h     
      4 tf_5  k     
      5 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      dm_for_filter() |> dm_rm_pk(tf_6) |> get_all_keys()
    Output
      $pks
      # A tibble: 5 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      dm_for_filter() |> dm_rm_pk(tf_4, rm_referencing_fks = TRUE) |> get_all_keys()
    Warning <lifecycle_warning_deprecated>
      The `rm_referencing_fks` argument of `dm_rm_pk()` is deprecated as of dm 0.2.1.
      Please use the `fail_fk` argument instead.
      Note the different semantics: `fail_fk = FALSE` roughly corresponds to `rm_referencing_fks = TRUE`, but foreign keys are no longer removed.
    Output
      $pks
      # A tibble: 5 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_5  k     
      5 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      dm_for_filter() |> dm_rm_pk(columns = c) |> get_all_keys()
    Message <simpleMessage>
      Removing primary keys: |>
        dm_rm_pk(tf_2)
    Output
      $pks
      # A tibble: 5 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_3  f, f1 
      3 tf_4  h     
      4 tf_5  k     
      5 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      dm_for_filter() |> dm_rm_pk(columns = c(f, f1), fail_fk = FALSE) |>
        get_all_keys()
    Message <simpleMessage>
      Removing primary keys: |>
        dm_rm_pk(tf_3)
    Output
      $pks
      # A tibble: 5 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_4  h     
      4 tf_5  k     
      5 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      dm_for_filter() |> dm_rm_pk(fail_fk = FALSE) |> get_all_keys()
    Message <simpleMessage>
      Removing primary keys: |>
        dm_rm_pk(tf_1) |>
        dm_rm_pk(tf_2) |>
        dm_rm_pk(tf_3) |>
        dm_rm_pk(tf_4) |>
        dm_rm_pk(tf_5) |>
        dm_rm_pk(tf_6)
    Output
      $pks
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, pk_col <keys>
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      

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
      dm(x = tibble(a = c(1, 1))) |> dm_add_pk(x, a, check = TRUE)
    Error <dm_error_not_unique_key>
      (`a`) not a unique key of `x`.

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
      nyc_comp() |> dm_get_all_pks()
    Output
      # A tibble: 4 x 2
        table    pk_col           
        <chr>    <keys>           
      1 airlines carrier          
      2 airports faa              
      3 planes   tailnum          
      4 weather  origin, time_hour

