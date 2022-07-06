# `dm_set_colors()` works

    Code
      dm_nycflights_small() %>% dm_set_colors(blue = starts_with("air"), green = contains(
        "h")) %>% dm_get_colors()
    Output
       #0000FFFF  #0000FFFF  #00FF00FF    default  #00FF00FF 
      "airlines" "airports"  "flights"   "planes"  "weather" 

# datamodel-code for drawing

    Code
      dm_get_data_model(dm_for_filter(), column_types = TRUE)
    Condition
      Warning:
      Each row in `x` should match at most 1 row in `y`.
      i Row 21 of `x` matches multiple rows.
      i If multiple matches are expected, specify `multiple = "all"` in the join call to silence this warning.
    Output
      $tables
        table segment display
      1  tf_1    <NA>    <NA>
      2  tf_2    <NA>    <NA>
      3  tf_3    <NA>    <NA>
      4  tf_4    <NA>    <NA>
      5  tf_5    <NA>    <NA>
      6  tf_6    <NA>    <NA>
      
      $columns
         table column id type key  ref ref_col
      1   tf_1      a  1  int   1 <NA>    <NA>
      2   tf_1      b  2  chr   0 <NA>    <NA>
      3   tf_2      c  1  chr   1 <NA>    <NA>
      4   tf_2      d  2  int   0 tf_1       a
      5   tf_2      e  3  chr   0 <NA>    <NA>
      6   tf_2     e1  4  int   0 <NA>    <NA>
      7   tf_3      f  1  chr   0 <NA>    <NA>
      8   tf_3     f1  2  int   0 <NA>    <NA>
      9   tf_3      g  3  chr   0 <NA>    <NA>
      10  tf_4      h  1  chr   1 <NA>    <NA>
      11  tf_4      i  2  chr   0 <NA>    <NA>
      12  tf_4      j  3  chr   0 <NA>    <NA>
      13  tf_4     j1  4  int   0 <NA>    <NA>
      14  tf_5     ww  1  int   0 <NA>    <NA>
      15  tf_5      k  2  int   1 <NA>    <NA>
      16  tf_5      l  3  chr   0 tf_4       h
      17  tf_5      m  4  chr   0 tf_6       n
      18  tf_6     zz  1  int   0 <NA>    <NA>
      19  tf_6      n  2  chr   2 <NA>    <NA>
      20  tf_6      o  3  chr   1 <NA>    <NA>
      21  tf_3  f, f1 NA <NA>   1 <NA>    <NA>
      22  tf_2  e, e1 NA <NA>   0 tf_3   f, f1
      23  tf_4  j, j1 NA <NA>   0 tf_3   f, f1
      
      $references
      # A tibble: 5 x 6
        table column ref   ref_col ref_id ref_col_num
        <chr> <chr>  <chr> <chr>    <int>       <int>
      1 tf_2  d      tf_1  a            1           1
      2 tf_2  e, e1  tf_3  f, f1        2           1
      3 tf_4  j, j1  tf_3  f, f1        3           1
      4 tf_5  l      tf_4  h            4           1
      5 tf_5  m      tf_6  n            5           1
      
      attr(,"class")
      [1] "data_model"

# helpers

    Code
      dm_get_all_columns(dm_for_filter())
    Output
      # A tibble: 20 x 3
         table column    id
         <chr> <chr>  <int>
       1 tf_1  a          1
       2 tf_1  b          2
       3 tf_2  c          1
       4 tf_2  d          2
       5 tf_2  e          3
       6 tf_2  e1         4
       7 tf_3  f          1
       8 tf_3  f1         2
       9 tf_3  g          3
      10 tf_4  h          1
      11 tf_4  i          2
      12 tf_4  j          3
      13 tf_4  j1         4
      14 tf_5  ww         1
      15 tf_5  k          2
      16 tf_5  l          3
      17 tf_5  m          4
      18 tf_6  zz         1
      19 tf_6  n          2
      20 tf_6  o          3

---

    Code
      dm_get_all_column_types(dm_for_filter())
    Output
      # A tibble: 20 x 4
         table column    id type 
         <chr> <chr>  <int> <chr>
       1 tf_1  a          1 int  
       2 tf_1  b          2 chr  
       3 tf_2  c          1 chr  
       4 tf_2  d          2 int  
       5 tf_2  e          3 chr  
       6 tf_2  e1         4 int  
       7 tf_3  f          1 chr  
       8 tf_3  f1         2 int  
       9 tf_3  g          3 chr  
      10 tf_4  h          1 chr  
      11 tf_4  i          2 chr  
      12 tf_4  j          3 chr  
      13 tf_4  j1         4 int  
      14 tf_5  ww         1 int  
      15 tf_5  k          2 int  
      16 tf_5  l          3 chr  
      17 tf_5  m          4 chr  
      18 tf_6  zz         1 int  
      19 tf_6  n          2 chr  
      20 tf_6  o          3 chr  

