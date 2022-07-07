# `dm_set_colors()` works

    Code
      dm_nycflights_small() %>% dm_set_colors(blue = starts_with("air"), green = contains(
        "h")) %>% dm_get_colors()
    Output
       #0000FFFF  #0000FFFF  #00FF00FF    default  #00FF00FF 
      "airlines" "airports"  "flights"   "planes"  "weather" 

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

