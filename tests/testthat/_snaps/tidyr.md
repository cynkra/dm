# key tracking works

    Code
      zoomed_dm() %>% unite("new_col", c, e) %>% dm_update_zoomed() %>% get_all_keys()
    Output
      $pks
      # A tibble: 5 x 2
        table pk_cols
        <chr> <keys> 
      1 tf_1  a      
      2 tf_3  f, f1  
      3 tf_4  h      
      4 tf_5  k      
      5 tf_6  o      
      
      $fks
      # A tibble: 4 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_4        j, j1         tf_3         f, f1           no_action
      3 tf_5        l             tf_4         h               cascade  
      4 tf_5        m             tf_6         n               no_action
      
    Code
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_cols
        <chr> <keys> 
      1 tf_1  a      
      2 tf_2  c      
      3 tf_3  f, f1  
      4 tf_4  h      
      5 tf_5  k      
      6 tf_6  o      
      
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
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        dm_add_fk(tf_2, new_col, tf_6) %>% dm_zoom_to(tf_2) %>% separate(new_col, c(
        "c", "e"), remove = TRUE) %>% dm_update_zoomed() %>% get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_cols
        <chr> <keys> 
      1 tf_1  a      
      2 tf_2  c      
      3 tf_3  f, f1  
      4 tf_4  h      
      5 tf_5  k      
      6 tf_6  o      
      
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
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        dm_add_fk(tf_2, new_col, tf_6) %>% dm_zoom_to(tf_2) %>% separate(new_col, c(
        "c", "e"), remove = FALSE) %>% dm_update_zoomed() %>% get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_cols
        <chr> <keys> 
      1 tf_1  a      
      2 tf_2  c      
      3 tf_3  f, f1  
      4 tf_4  h      
      5 tf_5  k      
      6 tf_6  o      
      
      $fks
      # A tibble: 6 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action
      6 tf_2        new_col       tf_6         o               no_action
      

# output for compound keys

    Code
      unite_weather_dm <- nyc_comp() %>% dm_zoom_to(weather) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_weather_dm %>% get_all_keys()
    Output
      $pks
      # A tibble: 3 x 2
        table    pk_cols
        <chr>    <keys> 
      1 airlines carrier
      2 airports faa    
      3 planes   tailnum
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 flights     carrier       airlines     carrier         no_action
      2 flights     dest          airports     faa             no_action
      3 flights     tailnum       planes       tailnum         no_action
      
    Code
      unite_weather_dm %>% get_all_keys()
    Output
      $pks
      # A tibble: 3 x 2
        table    pk_cols
        <chr>    <keys> 
      1 airlines carrier
      2 airports faa    
      3 planes   tailnum
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 flights     carrier       airlines     carrier         no_action
      2 flights     dest          airports     faa             no_action
      3 flights     tailnum       planes       tailnum         no_action
      
    Code
      unite_flights_dm <- nyc_comp() %>% dm_zoom_to(flights) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_flights_dm %>% get_all_keys()
    Output
      $pks
      # A tibble: 4 x 2
        table    pk_cols          
        <chr>    <keys>           
      1 airlines carrier          
      2 airports faa              
      3 planes   tailnum          
      4 weather  origin, time_hour
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 flights     carrier       airlines     carrier         no_action
      2 flights     dest          airports     faa             no_action
      3 flights     tailnum       planes       tailnum         no_action
      
    Code
      unite_flights_dm %>% get_all_keys()
    Output
      $pks
      # A tibble: 4 x 2
        table    pk_cols          
        <chr>    <keys>           
      1 airlines carrier          
      2 airports faa              
      3 planes   tailnum          
      4 weather  origin, time_hour
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 flights     carrier       airlines     carrier         no_action
      2 flights     dest          airports     faa             no_action
      3 flights     tailnum       planes       tailnum         no_action
      
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% separate(origin, c("o1", "o2"), sep = "^..",
      remove = TRUE) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 54
      Primary keys: 3
      Foreign keys: 3
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% separate(origin, c("o1", "o2"), sep = "^..",
      remove = FALSE) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 55
      Primary keys: 4
      Foreign keys: 4

