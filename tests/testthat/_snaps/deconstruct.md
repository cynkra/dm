# `new_fks_in()` generates expected tibble

    Code
      new_fks_in(child_uuid = "flights-uuid", child_fk_cols = new_keys(list(list(
        "origin", "dest"))), parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_uuid   child_fk_cols parent_key_cols
        <chr>        <dm_keys>     <dm_keys>      
      1 flights-uuid origin, dest  faa            

# `new_fks_out()` generates expected tibble

    Code
      new_fks_out(child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_uuid = "airports-uuid", parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_fk_cols parent_uuid   parent_key_cols
        <dm_keys>     <chr>         <dm_keys>      
      1 origin, dest  airports-uuid faa            

# keyed_by()

    Code
      keyed_by(x, y)
    Output
        a 
      "b" 
    Code
      keyed_by(y, x)
    Output
        b 
      "a" 

# semi_join()

    Code
      dm(x, y, r = semi_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y)
    Code
      dm(x, y, r = semi_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(x, a, r)

# uks_df_from_keys_info()

    Code
      dm %>% dm_get_keyed_tables_impl() %>% uks_df_from_keys_info() %>%
        to_snapshot_json()
    Output
      # A tibble: 6 x 2
        table uks             
        <chr> <list>          
      1 tf_1  <tibble [0 x 1]>
      2 tf_2  <tibble [0 x 1]>
      3 tf_3  <tibble [1 x 1]>
      4 tf_4  <tibble [0 x 1]>
      5 tf_5  <tibble [1 x 1]>
      6 tf_6  <tibble [0 x 1]>

