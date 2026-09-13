# print() and format() methods for subclass `dm_zoomed` work

    Code
      dm_for_filter() %>% dm_zoom_to(tf_5) %>% as_dm_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table A data frame 
            "tf_5"     "?? x 4" 

---

    Code
      dm_for_filter() %>% dm_zoom_to(tf_2) %>% as_dm_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table A data frame 
            "tf_2"     "?? x 4" 

---

    Code
      dm_for_filter() %>% dm_zoom_to(tf_2) %>% print(n = 2)
    Output
        c            d e        e1
        <chr>    <int> <chr> <int>
      1 elephant     2 D         4
      2 lion         3 E         5
      # i more rows

