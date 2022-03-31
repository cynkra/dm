# `pack_join()` works

    Code
      pack_join(df1, df2)
    Message
      Joining, by = "key"
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
      Joining, by = "key"
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
      # A tibble: 2 x 4
         col1 key   key3  df3$col3
        <int> <chr> <chr>    <int>
      1     1 a     a            3
      2     2 b     b            4

---

    `x` and `y` must share the same src, set `copy` = TRUE (may be slow)

---

    Code
      pack_join(df1, dm_fin$accounts, by = c(col1 = "id"), copy = TRUE)
    Output
      # A tibble: 2 x 3
         col1 key   `dm_fin$accounts`$district_id $frequency       $date
        <int> <chr>                         <int> <chr>            <int>
      1     1 a                                18 POPLATEK MESICNE  9213
      2     2 b                                 1 POPLATEK MESICNE  8457

---

    Code
      pack_join(df4, df5, by = c(df5 = "col"))
    Output
      # A tibble: 0 x 1
      # ... with 1 variable: df5 <tibble[,0]>

---

    Code
      pack_join(df5, df6, by = c(col = "df6"))
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: col <int>, df6 <tibble[,0]>

