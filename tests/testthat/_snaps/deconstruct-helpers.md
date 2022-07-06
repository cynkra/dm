# `new_fks_in()` generates expected tibble

    Code
      new_fks_in(child_table = "flights", child_fk_cols = new_keys(list(list("origin",
        "dest"))), parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_table child_fk_cols parent_key_cols
        <chr>       <keys>        <keys>         
      1 flights     origin, dest  faa            

# `new_fks_out()` generates expected tibble

    Code
      new_fks_out(child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_table = "airports", parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_fk_cols parent_table parent_key_cols
        <keys>        <chr>        <keys>         
      1 origin, dest  airports     faa            

# `new_keyed_tbl()` generates expected output

    Code
      dm <- dm_nycflights13(cycle = TRUE)
      keyed_tbl <- new_keyed_tbl(x = dm$airports, pk = new_keys(list("faa")), fks_in = new_fks_in(
        child_table = "flights", child_fk_cols = new_keys(list("origin", "dest")),
        parent_key_cols = new_keys(list("faa"))), fks_out = new_fks_out(
        child_fk_cols = new_keys(list("origin", "dest")), parent_table = "airports",
        parent_key_cols = new_keys(list("faa"))), uuid = "0a0c060f-0d01-0b03-0402-05090800070e")
      attr(keyed_tbl, "dm_key_info")
    Output
      $pk
      <list_of<character>[1]>
      [[1]]
      [1] "faa"
      
      
      $fks_in
      # A tibble: 2 x 3
        child_table child_fk_cols parent_key_cols
        <chr>       <keys>        <keys>         
      1 flights     origin        faa            
      2 flights     dest          faa            
      
      $fks_out
      # A tibble: 2 x 3
        child_fk_cols parent_table parent_key_cols
        <keys>        <chr>        <keys>         
      1 origin        airports     faa            
      2 dest          airports     faa            
      
      $uuid
      [1] "0a0c060f-0d01-0b03-0402-05090800070e"
      

