# decompose_table() decomposes tables nicely on chosen source

    Code
      out$parent_table
    Output
        aef_id     a e         f
         <int> <int> <chr> <int>
      1      1     1 c         1
      2      2     1 c         1
      3      3     2 b         0
    Code
      list_of_data_ts_parent_and_child()$parent_table
    Output
        aef_id     a e         f
         <int> <int> <chr> <int>
      1      1     1 c         1
      2      2     2 b         0
    Code
      out$child_table
    Output
            b     c d     aef_id
        <dbl> <int> <chr>  <int>
      1   1.1     5 a          1
      2   1.1     5 a          2
      3   4.2     6 b          3
      4   1.1     7 c          1
      5   1.1     7 c          2
    Code
      list_of_data_ts_parent_and_child()$child_table
    Output
            b     c d     aef_id
        <dbl> <int> <chr>  <int>
      1   1.1     5 a          1
      2   4.2     6 b          2
      3   1.1     7 c          1

