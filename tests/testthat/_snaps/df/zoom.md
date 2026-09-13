# print() and format() methods for subclass `dm_zoomed` work

    Code
      dm_for_filter() %>% dm_zoom_to(tf_5) %>% as_dm_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table     A tibble 
            "tf_5"      "4 x 4" 

---

    Code
      dm_for_filter() %>% dm_zoom_to(tf_2) %>% as_dm_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table     A tibble 
            "tf_2"      "6 x 4" 

---

    Code
      dm_for_filter() %>% dm_zoom_to(tf_2) %>% print(n = 2)
    Output
      # Zoomed table: tf_2
      # A tibble:     6 x 4
        c            d e        e1
        <chr>    <int> <chr> <int>
      1 elephant     2 D         4
      2 lion         3 E         5
      # i 4 more rows

