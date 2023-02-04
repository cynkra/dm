# `pack_join()` works

    Code
      pack_join(df1, df2)
    Message
      Joining with `by = join_by(key)`
    Output
      # A tibble: 2 x 3
         col1 key   df2$col2
        <int> <chr>    <int>
      1     1 a            3
      2     2 b            4

---

    Code
      pack_join(df1, df2, name = "packed_col")
    Message
      Joining with `by = join_by(key)`
    Output
      # A tibble: 2 x 3
         col1 key   packed_col$col2
        <int> <chr>           <int>
      1     1 a                   3
      2     2 b                   4

---

    Code
      pack_join(df1, df3, by = c(key = "key3"))
    Output
      # A tibble: 2 x 3
         col1 key   df3$col3
        <int> <chr>    <int>
      1     1 a            3
      2     2 b            4

---

    Code
      pack_join(df1, df3, by = c(key = "key3"), keep = TRUE)
    Output
      # A tibble: 2 x 3
         col1 key   df3$col3 $key3
        <int> <chr>    <int> <chr>
      1     1 a            3 a    
      2     2 b            4 b    

