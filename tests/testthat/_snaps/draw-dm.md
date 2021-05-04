# `dm_set_colors()` works

    Code
      dm_nycflights_small() %>% dm_set_colors(blue = starts_with("air"), green = contains(
        "h")) %>% dm_get_colors()
    Output
       #0000FFFF  #0000FFFF  #00FF00FF    default  #00FF00FF 
      "airlines" "airports"  "flights"   "planes"  "weather" 

---

    Code
      dm_nycflights_small() %>% dm_set_colors(blue = "flights", green = "airports") %>%
        dm_get_colors()
    Output
         default  #00FF00FF  #0000FFFF    default    default 
      "airlines" "airports"  "flights"   "planes"  "weather" 

# helpers

    Code
      dm_get_all_columns(dm_for_filter())
    Output
      # A tibble: 15 x 3
         table column    id
         <chr> <chr>  <int>
       1 tf_1  a          1
       2 tf_1  b          2
       3 tf_2  c          1
       4 tf_2  d          2
       5 tf_2  e          3
       6 tf_3  f          1
       7 tf_3  g          2
       8 tf_4  h          1
       9 tf_4  i          2
      10 tf_4  j          3
      11 tf_5  k          1
      12 tf_5  l          2
      13 tf_5  m          3
      14 tf_6  n          1
      15 tf_6  o          2

---

    Code
      dm_get_all_column_types(dm_for_filter())
    Output
      # A tibble: 15 x 4
         table column    id type 
         <chr> <chr>  <int> <chr>
       1 tf_1  a          1 int  
       2 tf_1  b          2 chr  
       3 tf_2  c          1 chr  
       4 tf_2  d          2 int  
       5 tf_2  e          3 chr  
       6 tf_3  f          1 chr  
       7 tf_3  g          2 chr  
       8 tf_4  h          1 chr  
       9 tf_4  i          2 chr  
      10 tf_4  j          3 chr  
      11 tf_5  k          1 int  
      12 tf_5  l          2 chr  
      13 tf_5  m          3 chr  
      14 tf_6  n          1 chr  
      15 tf_6  o          2 chr  

